require "image_tools/version"
require 'paint'
require 'debugger'
require 'mini_magick'
require 'fileutils'

module BuildOneX
  class ProcessUnit
    attr_accessor :destiny_path, :source_path,
      :source_w, :source_h,
      :destiny_w, :destiny_h,
      :valid, :exception

    def initialize path
      @source_path = path
      @image = MiniMagick::Image.open(@source_path)
      @source_h = @image.height
      @source_w = @image.width

      @destiny_path = @source_path.sub '2x/', '1x/'
      @destiny_h = @source_h / 2
      @destiny_w = @source_w / 2
      @valid = true
    rescue Exception => e
      @valid = false
      @exception = e
    end 

    def process
      @image.resize "#{@destiny_w}x#{@destiny_h}"      
      create_directory @destiny_path
      @image.write @destiny_path
    end

    private

    def create_directory path
      dirname = File.dirname(path)
      FileUtils.mkdir_p(dirname) unless File.directory?(dirname)
    end
  end

  def self.build args
    to_delete = []
    units = []
    commit = false
    
    args.each do |a|
      # debugger
      if a == "-commit"
        commit = true
      elsif a.include? "2x/" and (a.end_with? ".jpg" or a.end_with? ".jpeg" or a.end_with? ".png")
        units << ProcessUnit.new(a)        
      elsif a.include? "1x/" and (a.end_with? ".jpg" or a.end_with? ".jpeg" or a.end_with? ".png")
        to_delete << a
      end
    end

    puts "to delete ==========================================\n"
    to_delete.each do |i| 
      puts "#{i}\n" 
      if commit
        FileUtils.rm(i) 
        puts " ** deleted ** \n"
      end
    end
    puts "\n"

    puts "to process =========================================\n"

    units.select{ |i| i.valid }.each do |u|
      puts " source: #{u.source_path} w:#{u.source_w} h:#{u.source_h} "
      puts "destiny: #{u.destiny_path} w:#{u.destiny_w} h:#{u.destiny_h} "
      if commit
        u.process
        puts " ** commited ** \n"
      end

      puts "\n"
    end

    if units.select{ |i| !i.valid }.any?
      puts Paint["invalid ============================================\n", :red]
      units.select{ |i| !i.valid }.each do |u| 
        puts Paint["#{u.source_path}", :red]
        puts Paint["#{u.exception.message}", :yellow]        
      end
      puts "\n"
    end

  end

end
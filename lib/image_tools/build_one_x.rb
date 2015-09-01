require "image_tools/version"
require 'paint'

module ImageTools
  class ProcessUnit
    attr_accessor :destiny_path, :source_path,
      :source_w, :source_h,
      :destiny_w, :destiny_h

    def initialize path, h, w
      @source_path = path
      @image = MiniMagick::Image.open(@source_path)
      @source_h = @image.height
      @source_w = @image.width

      @destiny_path = @source_path.replace '2x', '1x'
      @destiny_h = @source_h / 2
      @destiny_w = @source_w / 2
    end 

    def process
      @image.resize = "#{@destiny_w}x#{@destiny_h}"      
      @image.write @destiny_path
    end
  end

  def self.rename args
    to_delete = []
    units = []
    commit = false
    
    args.each do |a|
      if a == "-commit"
        commit = true
      elsif a.include? "2x" and (a.ends_with? ".jpg" or a.ends_with? ".jpeg" or a.ends_with? ".png")
        units << ProcessUnit.new(a)        
      else
        to_delete << a
      end
    end

    puts "to delete ==========================================\n"
    to_delete.each do |i|
      puts "#{i}\n"
    end
    puts "\n"

    puts "to process =========================================\n"

    units.each do |u|
      puts " source: #{u.source_path} w:#{u.source_w} h:#{source_h} "
      puts "destiny: #{u.destiny_path} w:#{u.destiny_w} h:#{destiny_h} "
      if commit
        u.process
        puts " ** commited ** \n"
      end

      puts "\n"
    end
  end

end
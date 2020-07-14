module Watermark
  class << self
    # 判断是不是pdf
    def can_watermark?(blob)
      blob.content_type.start_with?("pdf")
    end

    # 源文件
    def temp_file(blob)
      temp_file = Tempfile.new(blob.filename, encoding: 'ascii-8bit')
      temp_file.write(blob.download)
    end

    # 打水印操作
    # return: 水印文件地址
    def watermarked(blob, mark_string = nil)
      temp_file = Watermark.temp_file(blob)
      if options[:mark_string].blank? || !Watermark.can_watermark?(blob)
        temp_file.path
      else
        water_file = Tempfile.new("water_water_#{blob.filename}", encoding: 'ascii-8bit')
        file_path = temp_file.path
        water_path = water_file.path
        PdfWatermark.watermark(
            mark_string, file_path, water_path,
            options: {
                angle: :diagonal,
                align: :center,
                font_color: '999999',
                transparent: 0.2,
                margin: [0, 0, 0, 0],
                mode: :repeat,
                max_font_size: 1000,
                font_size: '3%'
            }
        )
        water_path
      end
    end
  end
end
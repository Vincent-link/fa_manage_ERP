module Common
  class ExcelFormat
    class << self
      def first_format(options = {})
        attr = common_attributes.merge(
          pattern: 1, pattern_fg_color: :silver,
          font: Spreadsheet::Font.new('Calibri', size: 12, weight: :bold)
        ).merge(options)
        Spreadsheet::Format.new(attr)
      end

      def row_format(options= {})
        attr = common_attributes.merge(
          font: Spreadsheet::Font.new('Calibri', size: 12)
        ).merge(options)
        Spreadsheet::Format.new(attr)
      end

      def common_attributes
        {horizontal_align: :left, vertical_align: :center,}
      end
    end
  end
end

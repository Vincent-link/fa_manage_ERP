module Common
  class ExcelGenerator
    def self.gen(file_name = nil, book_data = [])
      book = gen_book book_data
      create_dir_if_not_exists file_name
      book.write(file_name)
      file_name
    end

    def self.gen_binary(book_data = [])
      file = Tempfile.new
      gen_book(book_data).write(file)
      file.path
    end

    def self.gen_book(book_data)
      book = ::Spreadsheet::Workbook.new
      book_data.each do |key, sheet_data|
        sheet = book.create_worksheet(name: key)
        sheet_data.each_with_index do |row, x|
          row.each_with_index do |cell, y|
            sheet[x, y] = cell
          end
        end
      end
      book
    end

    private

    def self.create_dir_if_not_exists(path)
      recursive = path.split('/')
      recursive.pop
      directory = ''
      recursive.each do |sub_directory|
        directory += sub_directory + '/'
        ::Dir.mkdir(directory) unless (::File.directory? directory)
      end
    end
  end
end
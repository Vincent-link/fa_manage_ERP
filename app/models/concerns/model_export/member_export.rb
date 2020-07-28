module ModelExport
  module MemberExport
    extend ActiveSupport::Concern

    class_methods do
      def export_xls_binary(members)
        data = members.as_json
      end
    end
  end
end

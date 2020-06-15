module BlobFileSupport
  extend ActiveSupport::Concern

  module ClassMethods
    def has_blob_upload *attrs
      attrs.each do |attr|
        define_method "#{attr}_file=" do |file_hash|
          if file_hash.present?
            if file_hash[:blob_id].present?
              self.send(attr).destroy! if self.send(attr).present?
              self.send("build_#{attr}_attachment", blob_id: file_hash[:blob_id])
            elsif file_hash[:id].blank?
              self.send(attr).destroy! if self.send(attr).present?
            end
          end
        end
      end
    end
  end
end
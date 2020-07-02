module BlobFileSupport
  extend ActiveSupport::Concern

  module ClassMethods
    def has_blob_upload *attrs
      attrs.each do |attr|
        define_method "#{attr}_file=" do |file_hash|
          file = nil
          if file_hash.present?
            if file_hash[:blob_id].present?
              self.send("#{attr}_attachment").delete if self.send(attr).present?
              raise '出现已保存的文件' if ActiveStorage::Attachment.where(blob_id: file_hash[:blob_id]).present?
              file = self.send("build_#{attr}_attachment", blob_id: file_hash[:blob_id])
            elsif file_hash[:id].blank?
              self.send("#{attr}_attachment").delete if self.send(attr).present?
            end
          end
          file
        end

        define_method "#{attr}_file_only_change" do |file_hash|
          file = nil
          if file_hash.present?
            if file_hash[:blob_id].present?
              raise '不能进行变更文件操作' unless self.send(attr).present?
              raise '出现已保存的文件' if ActiveStorage::Attachment.where(blob_id: file_hash[:blob_id]).present?
              file = self.try("#{attr}_attachment")
              file.update!(blob_id: file_hash[:blob_id])
            end
          end
          file
        end
      end
    end

    def have_blob_upload *attrs
      attrs.each do |attr|
        define_method "#{attr}_file=" do |file_hash|
          file = []
          if file_hash.present?
            if file_hash[:blob_id].present?
              self.send("#{attr}_attachments").where(id: file_hash[:id]).delete_all if self.send(attr).present?
              raise '出现已保存的文件' if ActiveStorage::Attachment.where(blob_id: file_hash[:blob_id]).present?
              [file_hash[:blob_id]].flatten.each do |blob_id|
                file << ActiveStorage::Attachment.create(name: attr, record_type: self.class.to_s, record_id: self.id, blob_id: blob_id)
              end
            elsif file_hash[:id].blank?
              self.send("#{attr}_attachments").delete_all if self.send(attr).present?
            end
          end
          file
        end

        define_method "#{attr}_file_add" do |file_hash|
          file = []
          if file_hash.present?
            if file_hash[:blob_id].present?
              raise '出现已保存的文件' if ActiveStorage::Attachment.where(blob_id: file_hash[:blob_id]).present?
              [file_hash[:blob_id]].flatten.each do |blob_id|
                file << ActiveStorage::Attachment.create(name: attr, record_type: self.class.to_s, record_id: self.id, blob_id: blob_id)
              end
            end
          end
          file
        end
      end
    end
  end
end
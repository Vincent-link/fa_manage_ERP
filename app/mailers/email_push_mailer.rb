class EmailPushMailer < ApplicationMailer
  def send_email_push(options, email_case, mark_string = nil)
    @email_params = email_case
    @dear_to = options[:dear_to]
    @share_link = []
    email_case.email_blobs.each do |email_blob|
      case email_blob.file_kind
      when EmailBlob.file_kind_water_value
        if email_blob.content_type.start_with?("pdf")
          attachments[email_blob.blob.filename] = File.read(Watermark.watermarked(email_blob.blob, mark_string))
        else
          attachments[email_blob.blob.filename] = email_blob.blob.open{|file| file}
        end
      when EmailBlob.file_kind_no_water_value
        attachments[email_blob.blob.filename] = email_blob.blob.open{|file| file}
      when EmailBlob.file_kind_link_value
        @share_link << email_blob.blob.service_url
      end
    end
    delivery_mail! email_params(options)
  end

  def email_params(options)
    {
        :from => options[:user]&.email || '还没有系统邮箱',
        :to => options[:to],
        :cc => options[:cc],
        :bcc =>options[:bcc],
        :subject => options[:subject],
        :user => options[:user]
    }
  end
end

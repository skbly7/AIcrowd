class S3Service
  def initialize(s3_key, shared_bucket = false)
    @s3_key      = s3_key
    @bucket_name = if shared_bucket
                     ENV['AWS_S3_SHARED_BUCKET']
                   else
                     ENV['AWS_S3_BUCKET']
                   end
    Aws.config.update({ region: ENV['AWS_REGION'] })
    @bucket = Aws::S3::Resource.new.bucket(@bucket_name)
  end

  def valid_key?
    @bucket.object(@s3_key).exists?
  end

  def expiring_url
    if s3_file_obj&.key.present?
      return s3_file_obj.presigned_url(:get, expires_in: 7.days.to_i)
    else
      return nil
    end
  end

  def public_url
    if s3_file_obj&.key.present?
      return s3_file_obj.public_url
    else
      return nil
    end
  end

  def s3_filename(s3_key)
    return nil if @s3_key.nil?

    @s3_key.split('/')[-1]
  end

  def s3_file_obj
    @s3_file_obj ||= Aws::S3::Object.new(bucket_name: @bucket_name, key: @s3_key)
  end

  def s3_filesize(s3_key)
    return 0 if @s3_key.blank? || @s3_file_obj.blank?

    filesize = number_to_human_size(s3_file_obj.content_length)
  end

  def s3_file(s3_key, filename)
    Aws::S3::Client.new.get_object(bucket: ENV['AWS_S3_BUCKET'], key: s3_key, response_target: filename)
  end

  def make_public_read
    resp = Aws::S3::Client.new.put_object_acl({
                                                acl:    "public-read",
                                                bucket: @bucket_name,
                                                key:    @s3_key
                                              })
  end

  def filestream
    begin
      resp = Aws::S3::Client.new.get_object(
        bucket: @bucket_name,
        key:    @s3_key)
      filestream = resp.body.read
    rescue Aws::S3::Errors::NoSuchKey
      filestream = nil
    end
    return filestream
  end
end

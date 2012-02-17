require 'hipchat'
require 'aws/s3'

class HipchatS3

  attr_reader :hipchat_client
  attr_accessor :s3_bucket

  def initialize(options = {})

    s3_creds = options.fetch(:s3, {:access_key_id => 'your-key', :secret_access_key => 'your-secret', :bucket => 'bucket'})
    hipchat_creds = options.fetch(:hipchat, {:api_token => 'your-token'})

    @s3_bucket = s3_creds.delete(:bucket)

    @hipchat_client = HipChat::Client.new(hipchat_creds[:api_token])
    AWS::S3::Base.establish_connection!(s3_creds)

  end

  def create_upload(path, room, username='fileuploader', message="File Uploaded", color='yellow')
    unless tar_exists?
      @hipchat_client[room].send(username, "You don't have tar installed on host", :notify => true, :color => color)
      return
    end

    file = tar_with_path(path)
    basename = File.basename(file)

    AWS::S3::S3Object.store(basename, open(path), @s3_bucket)
    @hipchat_client[room].send(username, "#{message} :: <a href=\"https://s3.amazonaws.com/#{@s3_bucket}/#{basename}\">#{basename}</a>", :notify => true, :color => color)
  end


private
  
  def tar_exists?
    `which tar`.strip != ""
  end

  def tar_with_path(path)
    cmd_path = `which tar`.strip
    tarred_path = "#{path}.tar.gz"
    `#{cmd_path} -czf #{tarred_path} #{path}`
    tarred_path
  end

end

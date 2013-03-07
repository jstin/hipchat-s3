require 'hipchat'
require 'aws/s3'

class HipchatS3

  attr_reader :hipchat_client
  attr_accessor :s3_bucket

  def initialize(options = {})

    s3_creds = options.fetch(:s3, {:access_key_id => 'your-key', :secret_access_key => 'your-secret', :bucket => 'bucket'}).symbolize_keys
    hipchat_creds = options.fetch(:hipchat, {:api_token => 'your-token'}).symbolize_keys

    @s3_bucket = s3_creds.delete(:bucket)

    @hipchat_client = HipChat::Client.new(hipchat_creds[:api_token])
    AWS::S3::Base.establish_connection!(s3_creds)

  end

  def create_compressed_upload(path, room, options={})
    options = {:username => 'fileuploader', :message => "File Uploaded", :color => 'yellow'}.merge(options)

    unless tar_exists?
      @hipchat_client[room].send(username, "You don't have tar installed on host", :notify => true, :color => color)
      return
    end

    file = tar_with_path(path)
    basename = "#{Time.now.strftime("%Y_%m_%d_%H_%M_%S")}/#{File.basename(file)}"

    AWS::S3::S3Object.store(basename, open(file), @s3_bucket, :access => :public_read)
    @hipchat_client[room].send(options[:username], "#{options[:message]} :: <a href=\"https://s3.amazonaws.com/#{@s3_bucket}/#{basename}\">#{basename}</a>", :notify => true, :color => options[:color])
  end

  def create_file_upload(file_path, room, options={})
    options = {:username => 'fileuploader', :message => "File Uploaded", :color => 'yellow'}.merge(options)
    basename = "#{Time.now.strftime("%Y_%m_%d_%H_%M_%S")}/#{File.basename(file_path)}"

    AWS::S3::S3Object.store(basename, open(file_path), @s3_bucket, :access => :public_read)
    @hipchat_client[room].send(options[:username], "#{options[:message]} :: <a href=\"https://s3.amazonaws.com/#{@s3_bucket}/#{basename}\">#{basename}</a>", :notify => true, :color => options[:color])
  end

  def create_inline_image(image_path, room, options={})
    options = {:thumbnail_path => nil, :username => 'fileuploader', :message => "Image Uploaded", :color => 'yellow'}.merge(options)

    timestamp = Time.now.strftime("%Y_%m_%d_%H_%M_%S")
    basename = File.basename(image_path)

    AWS::S3::S3Object.store("#{timestamp}/#{basename}", open(image_path), @s3_bucket, :access => :public_read)

    uri = "https://s3.amazonaws.com/#{@s3_bucket}/#{timestamp}/#{basename}"
    display_uri = uri

    if options[:thumbnail_path]
      thumb_basename = File.basename(options[:thumbnail_path])
      AWS::S3::S3Object.store("#{timestamp}/#{thumb_basename}", open(options[:thumbnail_path]), @s3_bucket, :access => :public_read)
      display_uri = "https://s3.amazonaws.com/#{@s3_bucket}/#{timestamp}/#{thumb_basename}"
    end

    @hipchat_client[room].send(options[:username], "#{options[:message]} <br> <a href=\"#{uri}\"><img src=\"#{display_uri}\" /></a>", :notify => true, :color => options[:color])
  end


private

  def tar_exists?
    `which tar`.strip != ""
  end

  def tar_with_path(path)
    cmd_path = `which tar`.strip
    tarred_path = "#{path}.tar.gz"
    `#{cmd_path} czf #{tarred_path} #{path}`
    tarred_path
  end

end

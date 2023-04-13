require 'csv'
require "net/ssh"
require 'net/sftp'
require 'pry'
require 'uri'
require 'dotenv'
require 'date'

Dotenv.load
class SFTPClient
  def initialize(host, user, password)
    @host = host
    @user = user
    @password = password
  end

  def connect
    data = []
    # filename = 'file.csv'
    file = Tempfile.create

    Net::SFTP.start(ENV["HOST"], ENV["USER_NAME"], password: ENV["PASS"]) do |sftp|
      # sftp.download('/out/OrgEntity.csv', filename)
      # File.write(file, sftp.download!("/out/COSTCENTER.CSV"))
      file = Tempfile.create

      File.write(file, sftp.download!("/out/OrgEntity.csv"))
      # File.write(file, sftp.download!("/out/employee.csv"))
      # sftp.download!("/out/OrgEntity.csv", file.path, :encoding => "iso-8859-1")


      CSV.foreach(file, encoding: 'iso-8859-1:utf-8', headers: true, col_sep: ';') do |row|
        data << row.to_h
      end
      # SAVE the data in a csv file to check
      #
      # # Specify the file name and mode (e.g., "w" for write)
      # file_name = 'data.csv'
      # mode = 'w'
      #
      #  Open the file in write mode
      # CSV.open(file_name, mode) do |csv|
      #   # Write the headers
      #   csv << data.first.keys
      #   # Write the data
      #   data.each { |hash| csv << hash.values }
      # end
    end
  end
end

sftp_client = SFTPClient.new(ENV["HOST"], ENV["USER_NAME"], ENV['PASS'] )
data = sftp_client.connect

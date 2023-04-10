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
    Net::SFTP.start(@host, @user, :password => @password) do |sftp|
      sftp.connect!
      io = StringIO.new
      data = sftp.connect.download!("/out/COSTCENTER.CSV", io.puts, read_size: 16000)

      # This 2 will be called to get those 2 csv data
      # cost_cen_data = sftp.connect.download!("/out/COSTCENTER.CSV", io.puts, read_size: 16000)
      # employee_data = sftp.connect.download!("/out/employee.csv", io.puts, read_size: 16000)
      #
      locations = []
      binding.pry
      CSV.parse(data.strip, :headers => true) do |row|
        binding.pry
        location = {
          'name': row[1],
          'city': row[2],
        }
        locations << location
      end


      # #this download the csv in raw string
      #
      # Approach 1 for csv + encoder issue
      # file = Tempfile.create
      # File.write(file, sftp.download!("/out/COSTCENTER.CSV"))
      # CSV.read(file, encoding: "ISO-8859-1")
      # CSV.read(file, encoding: "ISO-8859-3")



      # # if file system wanted, but it will create a file in system
      #
      # file = File.write('file.csv', data)
      # data_opener =  open("file.csv", "r") { |io| io.read.encode("UTF-8", invalid: :replace, replace: "") }

      # # No file creation way
      #
      # data_opener = org_data.encode("ISO-8859-3", invalid: :replace, replace: "")
      # choose one way to get the data_opener


      # # The Methods for splitting the code into Array of Hash format
      # splitter = data_opener.split("\r\n")
      # keys = splitter.shift.split(";")
      # this will create the records in hash way
      # result = splitter.map { |item| keys.zip(item.split(";")).to_h }

      # Find exact record
      # result.select {|result| result["CC_NO"] == "100151068" }
      # result.select {|result| result["LEAVE_DATE"] >= Date.today.strftime('%d.%m.%Y') }
      # result.select {|result| result["EMP_NO"] == "bcb" }

    end
    # @session ||= Net::SSH.start(@host, @user, :password=>@password, check_host_ip: false)
    # # @session ||= Net::SSH.start(ENV['HOST'], ENV['USER_NAME'], :password=>ENV['PASS'], check_host_ip: false)
    #
    # @sftp_client ||= Net::SFTP::Session.new(@session)
    # @sftp_client.connect!
  end

  def disconnect
    @sftp_client.close_channel
    @session.close
  end
end

sftp_client = SFTPClient.new(ENV["HOST"], ENV["USER_NAME"], ENV['PASS'] )
data = sftp_client.connect

# puts sftp_client
# sftp_client.disconnect


#  this is the demo code for download file from sftp server written in CNC Phoenix code base
# def download_file
#   Net::SFTP.start(creds[:SFTP], creds[:USERNAME], password: creds[:PASSWORD]) do |sftp|
#     File.write(path, sftp.download!("#{ENV['SFTP_PATH_ROOT']}/ID-Tracking_PRODCONF.txt"))
#   rescue Net::SFTP::StatusException
#     # Ignored
#   end
# rescue IOError
#   # Ignored
# end

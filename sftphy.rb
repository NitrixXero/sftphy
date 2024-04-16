# Copyright 2023 Elijah Gordon (NitrixXero) <nitrixxero@gmail.com>

# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

require 'optparse'
require 'net/sftp'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: ruby t.rb [options]"

  opts.on("-u", "--upload FILE", "Upload FILE via SFTP") do |file|
    options[:upload_file] = file
  end

  opts.on("-d", "--download REMOTE_PATH", "Download file from REMOTE_PATH via SFTP") do |remote_path|
    options[:download_remote_path] = remote_path
  end

  opts.on("-m", "--mkdir DIRECTORY_PATH", "Create directory on the SFTP server") do |directory_path|
    options[:create_directory] = directory_path
  end

  opts.on("--rmdir DIRECTORY_PATH", "Remove directory from the SFTP server") do |directory_path|
    options[:remove_directory] = directory_path
  end

  opts.on("--rmfile FILE_PATH", "Remove file from the SFTP server") do |file_path|
    options[:remove_file] = file_path
  end

  opts.on("-q", "--queryperm REMOTE_PATH", "Query permissions of a file/directory on the SFTP server") do |remote_path|
    options[:query_permissions] = remote_path
  end

  opts.on("-c", "--chmod PERMISSIONS", "Change permissions of a file/directory on the SFTP server") do |permissions|
    options[:change_permissions] = permissions
  end

  opts.on("-l", "--list REMOTE_PATH", "List files and directories at REMOTE_PATH on the SFTP server") do |remote_path|
    options[:list_remote_path] = remote_path
  end

  opts.on("-h", "--host HOST", "SFTP host") do |host|
    options[:host] = host
  end

  opts.on("-U", "--username USERNAME", "SFTP username") do |username|
    options[:username] = username
  end

  opts.on("-p", "--password PASSWORD", "SFTP password") do |password|
    options[:password] = password
  end

  opts.on("-r", "--remote REMOTE_PATH", "Remote path on the SFTP server") do |remote_path|
    options[:remote_path] = remote_path
  end
end.parse!

def upload_file_to_sftp(host, username, password, remote_path, local_path)
  begin
    Net::SFTP.start(host, username, password: password) do |sftp|
      sftp.upload!(local_path, remote_path)
    end
    puts "File uploaded successfully!"
  rescue StandardError => e
    puts "Error uploading file: #{e.message}"
  end
end

def download_file_from_sftp(host, username, password, remote_path, local_path)
  begin
    Net::SFTP.start(host, username, password: password) do |sftp|
      sftp.download!(remote_path, local_path)
    end
    puts "File downloaded successfully!"
  rescue StandardError => e
    puts "Error downloading file: #{e.message}"
  end
end

def create_directory_on_sftp(host, username, password, remote_path)
  begin
    Net::SFTP.start(host, username, password: password) do |sftp|
      sftp.mkdir!(remote_path)
    end
    puts "Directory created successfully!"
  rescue StandardError => e
    puts "Error creating directory: #{e.message}"
  end
end

def remove_directory_on_sftp(host, username, password, remote_path)
  begin
    Net::SFTP.start(host, username, password: password) do |sftp|
      sftp.rmdir!(remote_path)
    end
    puts "Directory removed successfully!"
  rescue StandardError => e
    puts "Error removing directory: #{e.message}"
  end
end

def remove_file_on_sftp(host, username, password, remote_path)
  begin
    Net::SFTP.start(host, username, password: password) do |sftp|
      sftp.remove!(remote_path)
    end
    puts "File removed successfully!"
  rescue StandardError => e
    puts "Error removing file: #{e.message}"
  end
end

def query_permissions_on_sftp(host, username, password, remote_path)
  begin
    permissions = nil
    Net::SFTP.start(host, username, password: password) do |sftp|
      attributes = sftp.stat!(remote_path)
      permissions = attributes.permissions.to_s(8)[-3, 3]
    end
    puts "Permissions for #{remote_path}: #{permissions}"
  rescue StandardError => e
    puts "Error querying permissions: #{e.message}"
  end
end

def change_permissions_on_sftp(host, username, password, remote_path, permissions)
  begin
    Net::SFTP.start(host, username, password: password) do |sftp|
      sftp.setstat(remote_path, permissions: permissions.to_i(8))
    end
    puts "Permissions for #{remote_path} changed to: #{permissions}"
  rescue StandardError => e
    puts "Error changing permissions: #{e.message}"
  end
end

def list_files_and_directories_on_sftp(host, username, password, remote_path)
  begin
    files = []
    directories = []
    Net::SFTP.start(host, username, password: password) do |sftp|
      sftp.dir.foreach(remote_path) do |entry|
        if entry.file?
          files << entry.name
        elsif entry.directory?
          directories << entry.name
        end
      end
    end
    puts "Files at #{remote_path}:"
    puts files.join("\n")
    puts "\nDirectories at #{remote_path}:"
    puts directories.join("\n")
  rescue StandardError => e
    puts "Error listing files and directories: #{e.message}"
  end
end

if options[:upload_file]
  if options[:host] && options[:username] && options[:password] && options[:remote_path]
    upload_file_to_sftp(options[:host], options[:username], options[:password], options[:remote_path], options[:upload_file])
  else
    puts "Please provide all the required options for uploading."
  end
elsif options[:download_remote_path]
  if options[:host] && options[:username] && options[:password] && options[:remote_path]
    download_file_from_sftp(options[:host], options[:username], options[:password], options[:download_remote_path], options[:download_remote_path].split('/').last)
  else
    puts "Please provide all the required options for downloading."
  end
elsif options[:create_directory]
  if options[:host] && options[:username] && options[:password] && options[:create_directory]
    create_directory_on_sftp(options[:host], options[:username], options[:password], options[:create_directory])
  else
    puts "Please provide all the required options for creating a directory."
  end
elsif options[:remove_directory]
  if options[:host] && options[:username] && options[:password] && options[:remove_directory]
    remove_directory_on_sftp(options[:host], options[:username], options[:password], options[:remove_directory])
  else
    puts "Please provide all the required options for removing a directory."
  end
elsif options[:remove_file]
  if options[:host] && options[:username] && options[:password] && options[:remove_file]
    remove_file_on_sftp(options[:host], options[:username], options[:password], options[:remove_file])
  else
    puts "Please provide all the required options for removing a file."
  end
elsif options[:query_permissions]
  if options[:host] && options[:username] && options[:password] && options[:query_permissions]
    query_permissions_on_sftp(options[:host], options[:username], options[:password], options[:query_permissions])
  else
    puts "Please provide all the required options for querying permissions."
  end
elsif options[:change_permissions]
  if options[:host] && options[:username] && options[:password] && options[:remote_path] && options[:change_permissions]
    change_permissions_on_sftp(options[:host], options[:username], options[:password], options[:remote_path], options[:change_permissions])
  else
    puts "Please provide all the required options for changing permissions."
  end
elsif options[:list_remote_path]
  if options[:host] && options[:username] && options[:password] && options[:list_remote_path]
    list_files_and_directories_on_sftp(options[:host], options[:username], options[:password], options[:list_remote_path])
  else
    puts "Please provide all the required options for listing files and directories."
  end
else
  puts "Usage: ruby sftphy.rb [--help]"
end

=begin

This file manage the creation of devices in apple

=end



#Function to check if there is any device information in the commit
#If there is info, then register the device in apple
#The device has to be in this format in the commit
#[device=Name of device=]
#Example: [device=Pedro iphone 5=9234929349234]
def device_func_check_for_new_devices_in_commits(app_information:)
    
    new_devices =  app_information[:changelog].scan( /\[device=(.*?)\]/)

    if new_devices.length > 0
        puts "There are new devices (#{new_devices.length}) to register in the commit message".green
        
        added_devices = []
        
        new_devices.each do |device_info|
            device_info_clean_split = device_info[0].split('=')
        
            name = device_info_clean_split[0]
            udid = device_info_clean_split[1]
        
            puts "New Device: #{name} - #{udid}".green
            device_func_register_device_to_apple(name: name, udid: udid)
            added_devices.push({title: "Name: #{name}", value: "#{udid}", short: false})
        end
        
        slack_func_notify_new_devices(added_devices: added_devices)
        
    else
        puts "No new devices to register".green
    end

end

#Function that connects to apple and adds the device that is in the params
def device_func_register_device_to_apple(name:, udid:)
        
    register_device(name: name, 
                    udid: udid, 
                    username: ENV["PRIVATE_ITUNES_USERNAME"],
                    team_id: ENV["PRIVATE_TEAM_NUMBER"])

    private_certificates_type_list_with_coma = ENV["PRIVATE_CERTIFICATES_TYPE_ARRAY"]
    private_certificates_type_array = private_certificates_type_list_with_coma.split(",")
                
    private_certificates_type_array.each do |certificate|
        match(type: certificate, force: true, verbose: true)
    end
                        
end
=begin

This file has all the logic related to send messages to slack

#The channel is set in the ENV["SLACK_URL"]

=end


#Notify via slack channel a generic message with the default payloads
def slack_func_notify(message_text:)
    slack(
        message: message_text,
        success: true,
        default_payloads: [:lane, :git_branch, :git_author],
        icon_url: ENV["SLACK_ICON"],
        username: "fastlane - #{ENV["PRIVATE_APP_NAME"]}")
end











#esta funcion por ahora queda out 

#Notify via slack channel that a new build is vailable 
#The channel is set in the ENV["SLACK_URL"]
def slack_func_notify_new_version(message_text:, scheme_name:, config_type:, platform:)

    if ENV["IOS_OR_ANDROID"] == "IOS"
        ipa_path = Actions.lane_context[SharedValues::IPA_OUTPUT_PATH]
        file_size = sh("du -sh #{ipa_path} | cut -f1")
    elsif 
        apk_path = lane_context[SharedValues::GRADLE_APK_OUTPUT_PATH]
        file_size = sh("du -sh #{apk_path} | cut -f1") 
    end

    platform_url = slack_func_get_platform_specific_url(platform: platform, scheme_name: scheme_name)

    payload = {
        "Build Date" => Time.new.to_s,
        "Scheme" => scheme_name,
        "Config" => config_type,
        "Size" => file_size, 
        "Url #{platform}" => platform_url
    }

    slack(
        message: message_text,
        success: true,
        icon_url: ENV["SLACK_ICON"],
        username: "fastlane - #{ENV["PRIVATE_APP_NAME"]}",
        payload: payload)

end

#Notify a list of new device has been added to apple
#The list needs to have the next format
#[{title: "", value: "", short: false}]
def slack_func_notify_new_devices(added_devices:)

    slack(
        message: "New devices registered in Apple",
        success: true,
        icon_url: ENV["SLACK_ICON"],
        username: "fastlane - #{ENV["PRIVATE_APP_NAME"]}",
        attachment_properties: { fields: added_devices })

end

#Notify an error of the lane and show de error that fastlane has
def slack_func_notify_error_in_lane(exception:)

    payload = {
        "Build Date" => Time.new.to_s,
        "Error Message" => exception.message
    }

    slack(
        message: "#{ENV["PRIVATE_APP_NAME"]} App build stop with error",
        success: false,
        icon_url: ENV["SLACK_ICON"],
        username: "fastlane - #{ENV["PRIVATE_APP_NAME"]}",
        payload: payload)

end

# ================ HELPERS ====================



#TODO: Esta hya que modificarla 
def slack_func_get_platform_specific_url(platform:, scheme_name:)

    platform_url = ""

    if platform == "fabric"

        if scheme_name == ENV["PRIVATE_SCHEME_NAME_DEV"]
            bundle_id = ENV["PRIVATE_BUNDLE_ID_DEV"]
        else
            bundle_id = ENV["PRIVATE_BUNDLE_ID_PROD"]
        end

        platform_url = "https://fabric.io/#{ENV["PRIVATE_FABRIC_URL_NAME"]}/ios/apps/#{bundle_id}/beta/releases/latest"
    
    elsif platform == "itunes"

        platform_url = "itunes.com"

    end 

    return platform_url
end



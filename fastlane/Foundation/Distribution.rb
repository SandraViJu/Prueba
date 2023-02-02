=begin

Hay que pensar que esto yiene que funciona para ios y para android y solo cambiar la info den los archivos de configuracion 



In this file is the logic to end the generated versions to different platforms 

- Fabric
- TestFlight
- Itunes

=end

def distribution_func_send_to_fabric(app_information:, platform_type:)  

    version_info = version_func_get_version(platform_type:platform_type)
    fabric_build_number = version_info[:build_number]

    # set other information for fabric
    fabric_app_name = app_information[:app_name]
    fabric_changelogs_description = app_information[:changelog]
    fabric_notes = "Version #{fabric_build_number} from #{fabric_app_name} \n\n#{fabric_changelogs_description}"    
    fabric_groups = nil
    fabric_mails = nil


    # SEND VERSION
    fabric_groups = ""
    fabric_mails = ""
    if platform_type == CONST_PROJECT_TYPE__IOS
        if app_information[:environment] == CONST_PROJECT_ENVIRONMENT__PROD
            fabric_groups = ENV["PRIVATE_IOS_FABRIC_GROUPS_PROD"]
            fabric_mails = ENV["PRIVATE_IOS_FABRIC_MAILS_PROD"]
        else 
            fabric_groups = ENV["PRIVATE_IOS_FABRIC_GROUPS_DEV"]
            fabric_mails = ENV["PRIVATE_IOS_FABRIC_MAILS_DEV"]
        end 
    elsif
        if app_information[:environment] == CONST_PROJECT_ENVIRONMENT__PROD
            fabric_groups = ENV["PRIVATE_ANDROID_FABRIC_GROUPS_PROD"]
            fabric_mails = ENV["PRIVATE_ANDROID_FABRIC_MAILS_PROD"]
        else 
            fabric_groups = ENV["PRIVATE_ANDROID_FABRIC_GROUPS_DEV"]
            fabric_mails = ENV["PRIVATE_ANDROID_FABRIC_MAILS_DEV"]
        end
    end

    if fabric_groups.length > 0 && fabric_mails.length > 0
        crashlytics(notes: fabric_notes, groups: fabric_groups, emails: fabric_mails)
    elsif fabric_groups.length > 0
        crashlytics(notes: fabric_notes, groups: fabric_groups)
    elsif fabric_mails.length > 0
        crashlytics(notes: fabric_notes, emails: fabric_mails)
    else
        crashlytics(notes: fabric_notes)
    end

    #update ios symbos to crashlytics
    if platform_type == CONST_PROJECT_TYPE__IOS
        upload_symbols_to_crashlytics
    end

    message_text = "#{app_information[:app_name]} App successfully released to Crashlytics!"
    slack_func_notify(message_text: message_text)
end



def distribution_func_send_to_firebase(app_information:, platform_type:)

    version_info = version_func_get_version(platform_type:platform_type)
    fabric_build_number = version_info[:build_number]

    # set other information for fabric
    fabric_app_name = app_information[:app_name]
    fabric_changelogs_description = app_information[:changelog]
    fabric_notes = "Version #{fabric_build_number} from #{fabric_app_name} \n\n#{fabric_changelogs_description}"    
    fabric_groups = nil
    fabric_mails = nil


    # SEND VERSION
    fabric_groups = ""
    fabric_mails = ""
    firebase_app_id = ""
    if platform_type == CONST_PROJECT_TYPE__IOS
        if app_information[:environment] == CONST_PROJECT_ENVIRONMENT__PROD
            fabric_groups = ENV["PRIVATE_IOS_FABRIC_GROUPS_PROD"]
            fabric_mails = ENV["PRIVATE_IOS_FABRIC_MAILS_PROD"]
            firebase_app_id = ENV["PRIVATE_FIREBASE_APP_ID_IOS_PROD"]
        else 
            fabric_groups = ENV["PRIVATE_IOS_FABRIC_GROUPS_DEV"]
            fabric_mails = ENV["PRIVATE_IOS_FABRIC_MAILS_DEV"]
            firebase_app_id = ENV["PRIVATE_FIREBASE_APP_ID_IOS_DEV"]
        end 
    elsif
        if app_information[:environment] == CONST_PROJECT_ENVIRONMENT__PROD
            fabric_groups = ENV["PRIVATE_ANDROID_FABRIC_GROUPS_PROD"]
            fabric_mails = ENV["PRIVATE_ANDROID_FABRIC_MAILS_PROD"]
            firebase_app_id = ENV["PRIVATE_FIREBASE_APP_ID_ANDROID_PROD"]
        else 
            fabric_groups = ENV["PRIVATE_ANDROID_FABRIC_GROUPS_DEV"]
            fabric_mails = ENV["PRIVATE_ANDROID_FABRIC_MAILS_DEV"]
            firebase_app_id = ENV["PRIVATE_FIREBASE_APP_ID_ANDROID_DEV"]
        end
    end

    firebase_login_token = ENV["FIREBASE_LOGIN_TOKEN"]
    if fabric_groups.length > 0 && fabric_mails.length > 0
        firebase_app_distribution(app: firebase_app_id, firebase_cli_token: firebase_login_token, testers: fabric_mails, groups: fabric_groups, release_notes: fabric_notes)
    elsif fabric_groups.length > 0
        firebase_app_distribution(app: firebase_app_id, firebase_cli_token: firebase_login_token, groups: fabric_groups, release_notes: fabric_notes)
    elsif fabric_mails.length > 0
        firebase_app_distribution(app: firebase_app_id, firebase_cli_token: firebase_login_token, testers: fabric_mails, release_notes: fabric_notes)
    else
        firebase_app_distribution(app: firebase_app_id, firebase_cli_token: firebase_login_token, release_notes: fabric_notes)
    end

    message_text = "#{app_information[:app_name]} App successfully released to Firebase!"
    slack_func_notify(message_text: message_text)
end









=begin



#------------------------- deploy -------------------------#
  
desc "Deploy a new version to the Google Play"
lane :deploy do
  ensure_git_status_clean
  gradle(task: "assembleRelease")
  fun_tag_build(
      git_branch_local: "HEAD",
      git_branch_remote: "master")
  upload_to_play_store(
validate_only: true,
skip_upload_screenshots: true,
skip_upload_images: true)
  fun_slack(
        message_text:"#{private_app_name} App successfully released to PlayStore!",
        scheme_name: private_scheme_name_prod,
        build_type: "Release",
        changelog: "")
end





=end
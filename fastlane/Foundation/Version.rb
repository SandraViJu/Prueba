=begin

This file containts all the functions that helps to generate or make changes related to the build. 

=end


# TODO l;a lpogica de abajo cogerla usarla con esto 
def version_func_get_version(platform_type:)

    build_number = ""
    version_number = ""

    if platform_type == CONST_PROJECT_TYPE__IOS
        version_number = Actions.lane_context[Actions::SharedValues::VERSION_NUMBER]
        build_number = Actions.lane_context[Actions::SharedValues::BUILD_NUMBER]
    elsif
        version_number = File.read("./../version.name").to_s  
        build_number = File.read("./../version.number").to_s  
    end

    {build_number: build_number, version_number: version_number}
end


#Increment the build number and the version number, then makes a commit and push to git with a tag
#The build number is set with the date and hour 
#The version number is incremented in the patch part by 0.0.1
#The push is made to the current working branch


def version_func_update_build_number_for_android(app_information:)
    version_func_update_build_number(app_information: app_information, platform_type: CONST_PROJECT_TYPE__ANDROID)
end

def version_func_update_build_number_for_ios(app_information:)
    version_func_update_build_number(app_information: app_information, platform_type: CONST_PROJECT_TYPE__IOS)
end

def version_func_update_build_number_for_hibrid(app_information:)
    #TODO, pendiente de hacer
end




# Aqui hay que ver si vale la pena solo pasra el tipo de plataforma o otda la info. 
def version_func_update_build_number(app_information:, platform_type:)

    #check that the git is clean so the only change that is commited is the new version number
    ensure_git_status_clean

    
    if platform_type == CONST_PROJECT_TYPE__IOS
        build_number = version_func_get_time_with_build_number_format() 
        #this functions increment/set the version in all the schemas of the project
        increment_build_number(build_number: build_number, xcodeproj: app_information[:ios][:xcodeproj])
        increment_version_number(bump_type: "patch")

    elsif
        build_number = File.read("./../version.number").to_i + 1
        version_name = version_name = File.read("./../version.name").to_s  
        parts = version_name.split('.')
        part_patch = parts[2].to_i
        part_patch = part_patch + 1
        parts[2] = part_patch.to_s
        version_name = parts.join('.')

        #set the new version in the files so the gradle can read it
        File.write("./../version.name", version_name)
        File.write("./../version.number", build_number)
    end

    version_info = version_func_get_version(platform_type:platform_type)
    final_version_number = version_info[:version_number]
    final_build_number = version_info[:build_number]


    message = "Build from fastlane #{final_build_number} #{final_version_number}"

    if platform_type == CONST_PROJECT_TYPE__IOS
        commit_version_bump(message: "#{message}. [skip ci]") #[skip ci] makes that de ci ignores this push
        
        
        #Hay que ver que tag pone y si puede poner un tag igual para nadorid y opara ios 
        add_git_tag
    elsif   

        git_commit( path: [ "./version.name", "./version.number" ], message: "#{message}. [skip ci]" )        

        add_git_tag(tag: "builds/#{final_version_number}/#{final_build_number}", build_number: final_version_number)
    end


    actual_branch_name = git_branch
    push_to_git_remote(local_branch: "HEAD", remote_branch: actual_branch_name)

    #if actual_branch_name == "develop"
    #    push_to_git_remote(local_branch: "HEAD", remote_branch: actual_branch_name)
    #else 
    #    push_to_git_remote(local_branch: actual_branch_name, remote_branch: actual_branch_name)
    #end
end


# ================ HELPERS ====================

def version_func_get_time_with_build_number_format() 
    time = Time.now.utc
    format_for_time = "%d%02d%02d%02d%02d"
    time_parts_to_format = [ time.year, time.month, time.day, time.hour, time.min ]
    time_with_format = format_for_time % time_parts_to_format
    return time_with_format[2..11]
end

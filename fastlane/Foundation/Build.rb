=begin

This file containts all the functions that helps to generate or make changes related to the build. 

=end


#Install pods, install and configure certs with given type, compile the ios app with given scheme   
def build_func_match_and_gym(app_information:)

    cocoapods(try_repo_update_on_error: true)
    
    match(
        type: app_information[:ios][:sign_config_type], 
        readonly: true, 
        clone_branch_directly: true, 
        verbose: true)

    export_method = build_func_get_correct_export_method_name(match_type: app_information[:ios][:sign_config_type])
          
    gym(
        scheme: app_information[:ios][:scheme_name],
        export_method: export_method,
        include_symbols: true,
        include_bitcode: true,
        output_name: "CompiledApp")
end

#Install gradle dependencies and compile version 
def build_func_gradle(app_information:)
    gradle( task: 'assemble', build_type: app_information[:android][:build_type])
end



# ================ HELPERS ====================

def build_func_get_correct_export_method_name(match_type:)

    #if match type is adhoc or appstore
    #export_method needs to be ad-hoc or app-store
    #this is a fix to use just one name for types
    export_method = match_type
    
    if export_method == "adhoc"
        export_method = "ad-hoc"
    end
    if export_method == "appstore"
        export_method = "app-store"
    end

    return export_method
end

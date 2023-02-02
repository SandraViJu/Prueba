=begin

This file contains all the functions that extends Git

=end

#Save changelog in a ENV variable
def git_func_save_changelog_in_env_var()
    ENV["PRIVATE_CHANGELOG"] = git_func_get_changelog()
end

#Get the changelog with defined params
#The range of commit to search is from actual commit to
#the last commit that has a build/ tag 
def git_func_get_changelog()

    #https://git-scm.com/docs/pretty-formats
    #Example of actual format
    #- (891cde1) Mon, 4 Nov 2019 12:10:42 +0100 
    #Fix delete habit name
    #body text

    pretty_format = "- (%h) %aD \n%s\n%b"

    changelog = changelog_from_git_commits(
        pretty: pretty_format,
        date_format: "short",
        tag_match_pattern: "builds/*" # ESTO CREO QUE ES DIFERENTE PARA CADA PLATAFORMA "version/*" para android SE deberia unificar 
    )
                                                  
    return "\n#{changelog}"                                           
end
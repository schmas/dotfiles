function has_aws_token_expired
    # Get the AWS credentials file path
    set -l aws_profile 'SSO-EzQuoteDeveloperRole'
    set -l credentials_file ~/.aws/credentials

    # Check if the credentials file exists
    if test -e $credentials_file
        # Extract the token expiration time for the SSO-EzQuoteDeveloperRole profile
        set -l token_expiration (aws configure get x_security_token_expires --profile $aws_profile)
        echo "Token Expiration: $token_expiration"

        # Get the current time in ISO format
        set -l current_time (date -u +"%Y-%m-%dT%H:%M:%SZ")

        # Convert the token expiration time to ISO format
        set -l expiration_time (date -u -d "$token_expiration" +"%Y-%m-%dT%H:%M:%SZ")

        echo "Current Time: $current_time"
        echo "Expiration Time: $expiration_time"

        # Check if the token has expired
        if test (date -d "$current_time" +%s) -gt (date -d "$expiration_time" +%s)
            echo "AWS security token for $aws_profile has expired."
            return 1
        else
            echo "AWS security token for $aws_profile is still valid."
            return 0
        end
    else
        echo "AWS credentials file not found."
    end
    return 0
end

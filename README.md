## KittyGPT

![Screenshot](screenshot.png)

A simple macOS client for Claude models. Supported models include Claude (instant and v2) via AWS Bedrock.

To use this application, you will need either:
* AWS credentials of an IAM user or session that has `bedrock-runtime:InvokeModel` permission. See 
AWS docs for the steps to [create IAM user access key](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html#Using_CreateAccessKey)
or [how to configure credentials file](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html).

Please note that while this application is open-source and free to use, the usage of AWS resources are not free. Ensure 
you are aware of the associated costs before using the application extensively.

## Key Features

* Prompt templates: you can create templates for prompts, allowing you to quickly generate structured input for the 
  API calls.

## Why I created this project

I needed to streamline my GenAI workflow, but I encountered several limitations with existing tools available in 
the market. They were either overly expensive, web-based (making me hesitant to trust them with my API key), or lacking 
the specific features I required. As a personal weekend challenge, I embarked on creating this project to learn SwiftUI 
and see how far I could go. The code was written with significant guidance and assistance from LLM chatbots itself.

## Credits

This project makes use of the following resources:

* [AWS Bedrock](https://aws.amazon.com/bedrock/) 
* icon.kitchen - The app icon was generated using resources from [icon.kitchen](https://icon.kitchen/)


## License

This project is licensed under the MIT License. Feel free to use, modify, and distribute the code according to the terms of the license.


## Disclaimer

The models and APIs used by this application are developed and maintained by Anthropic, and AWS. This application is merely 
a wrapper that utilizes those engine's capabilities. For any issues related to the language model or its usage, please refer to the 
respective service's documentation and support channels.

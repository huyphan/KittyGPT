## KittyGPT

A simple macOS client of the `text-davinci-003` model of the OpenAI API, the same engine that powers ChatGPT. To use 
this application, you will need an API key from OpenAI. If you don't have one, you can generate an API key by visiting 
the [OpenAI API Keys](https://platform.openai.com/account/api-keys) page.

Please note that while this application is open-source and free to use, the usage of the OpenAI API is not free. Ensure 
you are aware of the associated costs before using the application extensively.

## Key Features

* Prompt templates: you can create your own templates for prompts, allowing you to quickly generate structured input for the 
  OpenAI API. When you first use the application, the [default template](https://github.com/huyphan/KittyGPT/blob/main/KittyGPT/Assets.xcassets/DefaultPrompts.dataset/prompts.json) is used


## Installation

Build this project by your own or download one of the [pre-built binaries](https://github.com/huyphan/KittyGPT/releases).


## Prompt template schema

This section will be documented soon, but if you are curious, the SwiftUI version of schema is defined in 
[the PromptConfigurationModel.swift](https://github.com/huyphan/KittyGPT/blob/main/KittyGPT/Data/PromptConfigurationModel.swift#L40-L42) file.


## Credits

This project makes use of the following resources:

* OpenAI API - The "text-davinci-003" engine is powered by the OpenAI API. Visit OpenAI for more information.
* icon.kitchen - The app icon was generated using resources from icon.kitchen. 
* www.appicon.co - Generate different app icon sizes.

## License

This project is licensed under the [GNU General Public License v3.0 (GPLv3)](https://www.gnu.org/licenses/gpl-3.0.en.html)

You can find a copy of the license in the LICENSE file.


## Disclaimer

The `text-davinci-003` engine is developed and maintained by OpenAI. This application is merely a wrapper that utilizes 
the engine's capabilities. For any issues related to the language model or its usage, please refer to OpenAI's 
documentation and support channels.

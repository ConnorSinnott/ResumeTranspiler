# ResumeTranspiler

### Boy, do I hate writing resumes in Word.

This application allows the editing of resumes through Pug 
and SASS while providing a print preview to work around.

In addition, current and historic resumes can be stored an managed
within an AWS S3 bucket using the provided `resumetranspiler` script.
The infrastructure required for this feature can be deployed through 
AWS CloudFormation using the `build` script so long as the local
instance of `awscli` has the correct credentials. 

Requirements:

-   `Docker`
-   `docker-compose`
-   Required for optional management feature:
    -   `awscli` 
    -   `aws-sam-cli`

## Use

### Resume Development

A local development server can be started by executing

`./resumetranspiler start-dev`

It can be accessed by visiting `localhost:3000`

The sever can be similarly stopped by executing

`./resumetranspiler stop-dev`

Changes made within the `_resume` folder will trigger
the development server to refresh any browser pointing at
`localhost:3000`

SCSS files are automatically converted, and can be included
into the pug as if it were a normal css file.

`e.g. link(rel='stylesheet' href="./style/layout.scss")`
    
### Resume Management

#### Use

To see which resumes are available for download, execute

`./resumetranspiler list`

To download a resume into the `_resume` folder, execute

`./resumetranspiler checkout [RESUME.zip]`

To upload the contents of _resume to aws, execute

`./resumetranspiler push`

Resumes can be deleted from AWS using

`./resumetranspiler delete [RESUME.zip]`

#### Deployment

To enable the management feature, an AWS CloudFormation stack
must be deployed. This requires that both `awscli` and `aws-sam-cli`
be installed and that the default profile for `awscli` have administrative
permissions.

It also requires an API key for [HTML/CSS to Image API](https://htmlcsstoimage.com/)
which the builder will prompt for.

With these requirements met, execute

`./build deploySAM`

To deploy the application.

Once the stack has been deployed, any computer with the same
`awscli` credentials can execute 

`./build generateEnv`

To configure access to the currently existing stack.

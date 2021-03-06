import sys
import os
import datetime

LIST_COMMAND = os.path.expandvars('aws s3 ls s3://$AWS_S3_BUCKET_NAME | grep -Eo "\S*.zip"')
DOWNLOAD_COMMAND = os.path.expandvars('aws s3 cp s3://$AWS_S3_BUCKET_NAME/{} /project/resume.zip')
UPLOAD_COMMAND = os.path.expandvars('aws s3 cp resume.zip s3://$AWS_S3_BUCKET_NAME/{}.zip')
DELETE_FROM_SERVER_COMMAND = os.path.expandvars('aws s3 rm --recursive s3://$AWS_S3_BUCKET_NAME/{}')
UPDATE_RESUME_OWNERSHIP = os.path.expandvars('chown -R $HOST_USER_ID:$HOST_USER_ID /project/resume')
EMPTY_RESUME_DIRECTORY_COMMAND = 'rm -rf /project/resume/*'
ZIP_RESUME_COMMAND = 'zip -r resume.zip resume';
UNZIP_RESUME_COMMAND = 'unzip resume.zip';
REMOVE_ZIP_COMMAND = 'rm resume.zip';

def _getDirectories():
    stream = os.popen(LIST_COMMAND)
    result = stream.read().strip()

    if len(result) > 0:
        return result.split('\n')
    else:
        return []

def _emptyResumeDirectory():
    os.system(EMPTY_RESUME_DIRECTORY_COMMAND)

def listDirectories():
    directories = _getDirectories()

    if len(directories) > 0:
        print '\n'.join(directories)
    else:
        print 'Server has no directories'

def checkoutDirectory(arguments):
    if len(arguments) < 1:
        print 'No directory to checkout'
        return

    directoryName = arguments[0]

    if not directoryName in _getDirectories():
        print 'Directory {} does not exist on the server'.format(directoryName)
        return

    _emptyResumeDirectory()

    copyCommand = DOWNLOAD_COMMAND.format(directoryName)

    os.system(copyCommand)

    os.system(UNZIP_RESUME_COMMAND)

    os.system(REMOVE_ZIP_COMMAND)

    os.system(UPDATE_RESUME_OWNERSHIP)

def deleteDirectory(arguments):
    if len(arguments) < 1:
        print 'No directory to delete'
        return

    directoryName = arguments[0]

    if not directoryName in _getDirectories():
        print 'Directory {} does not exist on the server'.format(directoryName)
        return

    deleteCommand = DELETE_FROM_SERVER_COMMAND.format(directoryName)

    os.system(deleteCommand)

def pushDirectory():
    date = datetime.date.today().strftime('%m-%d-%Y')

    if date in _getDirectories():
        deleteDirectory([date])

    zipCommand = ZIP_RESUME_COMMAND.format(date)

    os.system(zipCommand)

    uploadCommand = UPLOAD_COMMAND.format(date)

    os.system(uploadCommand)

    os.system(REMOVE_ZIP_COMMAND)

scriptArguments = sys.argv[1:]
command = scriptArguments.pop(0)
{
    "list": lambda: listDirectories(),
    "checkout": lambda: checkoutDirectory(scriptArguments),
    "push": lambda: pushDirectory(),
    "delete": lambda: deleteDirectory(scriptArguments)
}[command]()


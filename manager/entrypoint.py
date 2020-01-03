import sys
import os
import datetime

LIST_COMMAND = 'aws s3 ls s3://resumetranspiler | grep -Eo "\d{2}-\d{2}-\d{4}"'
DOWNLOAD_COMMAND = 'aws s3 cp --recursive s3://resumetranspiler/{} /project/resume'
UPLOAD_COMMAND = 'aws s3 cp --recursive /project/resume s3://resumetranspiler/{}'
DELETE_FROM_SERVER_COMMAND = 'aws s3 rm --recursive s3://resumetranspiler/{}'
EMPTY_RESUME_DIRECTORY_COMMAND = 'rm -rf /project/resume/*'

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

    _emptyResumeDirectory()

    copyCommand = DOWNLOAD_COMMAND.format(directoryName)

    os.system(copyCommand)

def deleteDirectory(arguments):
    if len(arguments) < 1:
        print 'No directory to delete'
        return

    directoryName = arguments[0]

    if not directoryName in _getDirectories():
        print 'Directory {} does not exist on the server'.format(directoryName)

    deleteCommand = DELETE_FROM_SERVER_COMMAND.format(directoryName)

    os.system(deleteCommand)

def pushDirectory():
    date = datetime.date.today().strftime('%m-%d-%Y')

    if date in _getDirectories():
        deleteDirectory([date])

    uploadCommand = UPLOAD_COMMAND.format(date)

    os.system(uploadCommand)

scriptArguments = sys.argv[1:]
command = scriptArguments.pop(0)
{
    "list": lambda: listDirectories(),
    "checkout": lambda: checkoutDirectory(scriptArguments),
    "push": lambda: pushDirectory(),
    "delete": lambda: deleteDirectory(scriptArguments)
}[command]()


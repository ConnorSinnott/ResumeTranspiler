import sys
import os

def _getDirectories():
    stream = os.popen('aws s3 ls s3://resumetranspiler | grep -Eo "\d{2}-\d{2}-\d{4}"')
    result = stream.read().strip()
    return result.split('\n')

def _emptyResumeDirectory():
    os.system('rm -rf /project/resume/*')

def listDirectories():
    print '\n'.join(_getDirectories())

def checkoutDirectory(arguments):
    if len(arguments) < 1:
        print 'No directory to checkout'
        return

    directoryName = arguments[0]

    if not directoryName in _getDirectories():
        print 'Directory {} does not exist on the server'.format(directoryName)

    _emptyResumeDirectory()

    copyCommand = 'aws s3 cp --recursive s3://resumetranspiler/{} /project/resume'.format(directoryName)

    os.system(copyCommand)

def pushDirectory():
    print "Pushing directory"

scriptArguments = sys.argv[1:]
command = scriptArguments.pop(0)
{
    "list": lambda: listDirectories(),
    "checkout": lambda: checkoutDirectory(scriptArguments),
    "push": lambda: pushDirectory()
}[command]()


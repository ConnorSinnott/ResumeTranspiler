import sys

def listDirectories():
    print 'Listing directories'

def checkoutDirectory(arguments):
    if len(arguments) < 1:
        print 'No directory to checkout'
        return

    directoryName = arguments[0]

    print 'Checking out directory {}'.format(directoryName)

def pushDirectory():
    print "Pushing directory"

scriptArguments = sys.argv[1:]
command = scriptArguments.pop(0)
{
    "list": lambda: listDirectories(),
    "checkout": lambda: checkoutDirectory(scriptArguments),
    "push": lambda: pushDirectory()
}[command]()


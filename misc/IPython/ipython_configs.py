
#IPython initialization options:

#`ipython qtconsole -h` will show all style names pygments can find on the system

ipython qtconsole --style=monkai --ConsoleWidget.font_family="Big Caslon" --ConsoleWidget.font_size=9 --IPythonWidget.width=100 --IPythonWidget.height=31
--IPythonQtConsoleApp.hide_menubar=False --IPythonQtConsoleApp.confirm_exit=False --IPythonQtConsoleApp.maximize=False --IPythonWidget.banner=''

#IPythonQtConsoleApp.display_banner
#IPythonWidget.banner=''


#Config example:

# Configuration file for ipython-qtconsole.
#`ipython qtconsole -h` will show all style names pygments can find on the system

c = get_config()

#IPython initialization options:
c.JupyterWidget.font_family = u'Source Code Pro'
c.JupyterWidget.font_size = 14
c.JupyterWidget.clear_on_kernel_restart=True
c.JupyterWidget.confirm_restart=True
c.JupyterWidget.banner=''
c.ZMQInteractiveShell.colors = 'Linux'
c.JupyterWidget.buffer_size = 1000
c.JupyterWidget.width=88
c.JupyterWidget.height=28
c.JupyterQtConsoleApp.hide_menubar=True
c.JupyterQtConsoleApp.maximize=False
c.JupyterQtConsole.display_banner=False
c.JupyterQtConsoleApp.display_banner=False
c.JupyterQtConsoleApp.confirm_exit=False
c.JupyterQtConsoleApp.stylesheet=u''
#c.JupyterWidget.syntax_style = u'tango'
#c.JupyterWidget.syntax_style = u'fruity'
#c.JupyterWidget.syntax_style = u'manni'
c.JupyterWidget.syntax_style = u'monokai'
#c.TerminalInteractiveShell.confirm_exit = False

# c.IPythonWidget.in_prompt = 'In [<span class="in-prompt-number">%i</span>]: '
# c.IPythonWidget.out_prompt = 'Out[<span class="out-prompt-number">%i</span>]: '
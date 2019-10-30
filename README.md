# Enroll Template Project

This project aspires to be a competent plug-and-play template
to use as a starting point for applications that need authorized
access via an email and password.

Features in this template:

- Setup script to create and install components of the application.

- References project-specific values in **setup_names**.
  - An empty **setup_names** template is provided with the
    name **setup_names_template**
  - I recommend copying **setup_names_template** to
    **setup_names_custom**, setting the values in the new
    file, then making a sym-copy to **setup_names**:
    ~~~sh
    cp -s setup_names_custom setup_names
    ~~~
  - Peruse **setup_names_template** for the list of
    recognized variables and how the values are used.

- A XSL stylesheet, **setup_default.xsl** is provided to
  make changes to the **default.xsl** stylesheet provided
  by the Schema Framework.

## Commands Directory

The *commands* directory includes commands that perform actions
that cannot be directly performed by **schema.fcgi**.  In the
beginning, it is mainly sending emails to confirm registration
and to recover passwords.

### Emailing Commands

The command for emailing in this template (which you are not
required to use) uses **msmtp** to send emails.  For **msmtp**
to work, it needs a configuration file, typically named
*msmtprc*, a convention we will follow.  In this case, the
configuration file is local to the command and implicitly
loaded.

The repository includes a *msmtprc_template* that can be
used to help create a working template.  In my implementations,
I copy *msmtprc_template* to *msmtprc_custom*, and I enter the
site settings in the *msmtprc_custom* file, and then make a
symbolic link from *msmtprc_custom* to *msmtprc*.

~~~sh
cp -s msmtprc_custom msmtprc
~~~


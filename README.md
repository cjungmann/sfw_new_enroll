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
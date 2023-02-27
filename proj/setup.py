import os
import setuptools

version = os.getenv("VERSION", "0.0.1")

with open("README.md") as fp:
    long_description = fp.read()

setuptools.setup(
    name="__PROJECT_NAME__",
    version=version,
    description="__DESCRIPTION__",
    long_description=long_description,
    long_description_content_type="text/markdown",
    author="__AUTHOR__",
    author_email="__EMAIL__",
    url="__SCM_URL__",
    packages=setuptools.find_packages(exclude=["test.*", "test", "doc.*", "doc"]),
    install_requires=[],
    setup_requires=["pytest-runner"],
    tests_require=["pytest"],
    python_requires=">=3.9",
    classifiers=[
        "Development Status :: 4 - Beta",
        "Intended Audience :: Developers",
        "License :: OSI Approved :: Apache Software License",
        "Programming Language :: Python :: 3 :: Only",
        "Programming Language :: Python :: 3.9",
        "Programming Language :: Python :: 3.10",
        "Programming Language :: Python :: 3.11",
        "Typing :: Typed",
    ]
)
:: download https://thermo.flexnetoperations.com/control/thmo/viewRecentProductReleases
;::
;:: Self Test
;::
@echo off
:: https://www.java.com/en/download/windows-64bit.jsp
@echo Java self-test
	cd Java
	call Java_selftest.bat
	cd ..
:: https://www.python.org/ftp/python/2.7.18/python-2.7.18.amd64.msi install in C:\python27 followed by "c:\Python27\python -m pip install six"
@echo Python self-test
	cd Python
	call Python_selftest.bat
	cd ..
:: https://cran.r-project.org/bin/windows/base/ followed by install.packages(c("rjson","data.table")) and removing "C:\Program Files\R\R-3.6.1\bin\" from batch script "F:\Scripting Node Examples\User Scripts\R\R_selftest.bat" and corresponding use_case_R_[123].R files
@echo R self-test
	cd R
	call R_selftest.bat
	cd ..

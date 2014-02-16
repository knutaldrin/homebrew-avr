require 'formula'

class AvrBinutils < Formula
  url 'http://distribute.atmel.no/tools/opensource/Atmel-AVR-GNU-Toolchain/3.4.3/avr-binutils-2.23.2.tar.gz'
  homepage 'http://www.atmel.com/tools/ATMELAVRTOOLCHAINFORLINUX.aspx'
  sha256 '9d9327a3a9f42ff2753281ab9f074abe3e74aeea34ee7b9b2cff14c1bd4540f0'

  option 'disable-libbfd', 'Disable installation of libbfd.'

  def install

    if MacOS.version == :lion
      ENV['CC'] = ENV.cc
    end

    ENV['CPPFLAGS'] = "-I#{include}"

    args = ["--prefix=#{prefix}",
            "--infodir=#{info}",
            "--mandir=#{man}",
            "--disable-werror",
            "--enable-install-libbfd",
            "--enable-install-libiberty",
            "--disable-nls"]

#    unless build.include? 'disable-libbfd'
#      Dir.chdir "bfd" do
#        ohai "building libbfd"
#        system "./configure", "--enable-install-libbfd", *args
#        system "make"
#        system "make install"
#      end
#    end

    # brew's build environment is in our way
    ENV.delete 'CFLAGS'
    ENV.delete 'CXXFLAGS'
    ENV.delete 'LD'
    ENV.delete 'CC'
    ENV.delete 'CXX'

    if MacOS.version == :lion
      ENV['CC'] = ENV.cc
    end
    
    binutils_prep

    system "./configure", "--target=avr", *args
    
    system "make all-bfd TARGET-bfd=headers"
    
    # Force reconfig
    system "rm bfd/Makefile"
    
    system "make configure-host"
    
    system "make all"
    system "make install"
  end
  
  def binutils_prep
  	# Replace AC req
  	system "sed 's/AC_PREREQ(2.64)/AC_PREREQ(2.69)/g' ./configure.ac > ./configure.ac"
  	system "sed 's/AC_PREREQ(2.64)/AC_PREREQ(2.69)/g' ./libiberty/configure.ac > ./libiberty/configure.ac"
  	
  	system "autoconf"
  	Dir.chdir "libiberty" do
  		system "autoconf"
  	end
  end
  	
end

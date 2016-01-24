# CCPForge requires that svn checkouts be done with --username anonymous.
# This should be available in Homebrew by default in the near future.

class AnonymousSubversionDownloadStrategy < SubversionDownloadStrategy
  def quiet_safe_system(*args)
    super(*args + ["--username", "anonymous"])
  end
end

class Cutest < Formula
  desc "Constrained and Unconstrained Testing Environment on steroids"
  homepage "http://ccpforge.cse.rl.ac.uk/gf/project/cutest/wiki"
  head "http://ccpforge.cse.rl.ac.uk/svn/cutest/cutest/trunk", :using => AnonymousSubversionDownloadStrategy

  option "with-matlab", "Compile with Matlab support"
  option "with-single", "Compile without single support"

  depends_on "gsl"
  depends_on "optimizers/cutest/archdefs" => :build
  depends_on "optimizers/cutest/sifdecode" => :build
  depends_on :fortran
  env :std

  patch :DATA

  def install
    ENV.deparallelize
    toolset = (build.with? "matlab") ? "1" : "2"
    single = (build.with? "single") ? "y" : "n"
    precisions = (build.with? "single") ? ["single", "double"] : ["double"]

    if OS.mac?
      machine, key = (MacOS.prefer_64_bit?) ? %w[mac64 13] : %w[mac 12]
      arch = "osx"
      Pathname.new("cutest.input").write <<-EOF.undent
        #{key}
        2
        #{toolset}
        4
        nnyd#{single}
      EOF
    else
      machine = "pc64"
      arch = "lnx"
      Pathname.new("cutest.input").write <<-EOF.undent
        6
        2
        2
        #{toolset}
        4
        nnyd#{single}
      EOF
    end

    ENV["ARCHDEFS"] = Formula["archdefs"].libexec
    ENV["SIFDECODE"] = Formula["sifdecode"].libexec
    system "./install_cutest < cutest.input"

    # Build shared libraries.
    if OS.mac?
      so = "dylib"
      all_load = "-Wl,-all_load"
      noall_load = "-Wl,-noall_load"
      extra = ["-Wl,-undefined", "-Wl,dynamic_lookup"]
    else
      so = "so"
      all_load = "-Wl,-whole-archive"
      noall_load = "-Wl,-no-whole-archive"
      extra = []
    end
    precisions.each do |prec|
      cd "objects/#{machine}.#{arch}.gfo/#{prec}" do
        Dir["*.a"].each do |l|
          lname = File.basename(l, ".a") + "_#{prec}.#{so}"
          system ENV["FC"], "-fPIC", "-shared", all_load, l, noall_load, "-o", lname, *extra
        end
      end
    end

    # We only want certain links in /usr/local/bin.
    libexec.install Dir["*"]
    %w[cutest2matlab runcutest].each do |f|
      bin.install_symlink "#{libexec}/bin/#{f}"
    end

    include.install_symlink Dir["#{libexec}/include/*.h"]
    man1.install_symlink Dir["#{libexec}/man/man1/*.1"]
    man3.install_symlink Dir["#{libexec}/man/man3/*.3"]
    doc.install_symlink Dir["#{libexec}/doc/README*"], "#{libexec}/doc/pdf"
    lib.install_symlink "#{libexec}/objects/#{machine}.#{arch}.gfo/double/libcutest.a"
    lib.install_symlink "#{libexec}/objects/#{machine}.#{arch}.gfo/double/libcutest_double.#{so}"
    ln_sf "#{libexec}/objects/#{machine}.#{arch}.gfo/double/libcutest.a", "#{lib}/libcutest_double.a"
    ln_sf "#{libexec}/objects/#{machine}.#{arch}.gfo/double/libcutest_double.#{so}", "#{lib}/libcutest.#{so}"
    if build.with? "single"
      ln_sf "#{libexec}/objects/#{machine}.#{arch}.gfo/single/libcutest.a", "#{lib}/libcutest_single.a"
      ln_sf "#{libexec}/objects/#{machine}.#{arch}.gfo/single/libcutest_single.#{so}", "#{lib}/libcutest_single.#{so}"
    end

    s = <<-EOS.undent
      export CUTEST=#{opt_libexec}
    EOS
    if build.with? "matlab"
      s += <<-EOS.undent
        export MYMATLABARCH=#{machine}.#{arch}.gfo
        export MATLABPATH=$MATLABPATH:#{opt_libexec}/src/matlab
      EOS
    end
    (prefix / "cutest.bashrc").write(s)
    (prefix / "cutest.machine").write <<-EOF.undent
      #{machine}
      #{arch}
    EOF
  end

  def caveats
    s = <<-EOS.undent
      In your ~/.bashrc, add
      . #{prefix}/cutest.bashrc
    EOS
    if build.with? "matlab"
      s += <<-EOS.undent
        export MYMATLAB=/path/to/your/matlab

        Please also look at
          #{share}/doc/README.osx
        to set up your ~/.mexopts.sh.
      EOS
    end
    s
  end

  test do
    machine, arch = File.read(prefix / "cutest.machine").split
    ENV["ARCHDEFS"] = Formula["archdefs"].libexec
    ENV["SIFDECODE"] = Formula["sifdecode"].libexec
    ENV["CUTEST"] = libexec
    ENV["MYARCH"] = "#{machine}.#{arch}.gfo"
    ENV["MASTSIF"] = "#{libexec}/sif"

    cd testpath do
      %w[gen77 gen90 genc].each do |pkg|
        system "runcutest", "-p", pkg, "-D", "#{libexec}/sif/ROSENBR.SIF"
        system "runcutest", "-p", pkg, "-sp", "-D", "#{libexec}/sif/ROSENBR.SIF"
      end
    end
    ohai "Test results are in ~/Library/Logs/Homebrew/cutest."
  end
end

__END__
diff --git a/bin/install_cutest_alone b/bin/install_cutest_alone
index a7edfde..cc8474b 100755
--- a/bin/install_cutest_alone
+++ b/bin/install_cutest_alone
@@ -372,8 +372,8 @@ if [[ -e $CUTEST/versions/$VERSION ]]; then
     [[ $? == 0 ]] && exit 4
 fi
 
-MATLABGCC="gcc-4.3"
-MATLABGFORTRAN="gfortran-4.3"
+MATLABGCC="gcc"
+MATLABGFORTRAN="gfortran"
 matlab=""
 
 #echo $CMP

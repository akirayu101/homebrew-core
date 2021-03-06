class Fobis < Formula
  include Language::Python::Virtualenv

  desc "KISS build tool for automaticaly building modern Fortran projects"
  homepage "https://github.com/szaghi/FoBiS"
  url "https://files.pythonhosted.org/packages/2d/45/00c4c768f507401f9f95e978494b9964bc1d8cce841eb1dfffacd90278d9/FoBiS.py-2.2.9.1.tar.gz"
  sha256 "b40636dcb4cdec81d8b6aac8dcfab36957055ed310a466a06976136b9000b905"

  bottle do
    cellar :any_skip_relocation
    sha256 "4674226f6e3f186139d830939e0eaae938ea1be87079bd9d5d78c0ea6786fc14" => :high_sierra
    sha256 "4a5ffae28538666c6a0817d39c71ff49af65b374981b5fcdb6eac4fc1e936b4a" => :sierra
    sha256 "b0a89a6e67ff67b797c0aea5f8b1af9e2bb2b89470b592e59c56648dce487d71" => :el_capitan
    sha256 "bdba632e367a8136dfa4a43bd4bb11c0661b2670f227c159efc395b4fae37e0d" => :x86_64_linux
  end

  option "without-pygooglechart", "Disable support for coverage charts generated with pygooglechart"

  depends_on "gcc" # for gfortran
  depends_on "python@2"
  depends_on "graphviz" => :recommended

  resource "pygooglechart" do
    url "https://files.pythonhosted.org/packages/95/88/54f91552de1e1b0085c02b96671acfba6e351915de3a12a398533fc82e20/pygooglechart-0.4.0.tar.gz"
    sha256 "018d4dd800eea8e0e42a4b3af2a3d5d6b2a2b39e366071b7f270e9628b5f6454"
  end

  resource "graphviz" do
    url "https://files.pythonhosted.org/packages/fa/d1/63b62dee9e55368f60b5ea445e6afb361bb47e692fc27553f3672e16efb8/graphviz-0.8.2.zip"
    sha256 "606741c028acc54b1a065b33045f8c89ee0927ea77273ec409ac988f2c3d1091"
  end

  def install
    venv = virtualenv_create(libexec)
    venv.pip_install "pygooglechart" if build.with? "pygooglechart"
    venv.pip_install "graphviz" if build.with? "graphviz"
    venv.pip_install_and_link buildpath
  end

  test do
    (testpath/"test-mod.f90").write <<~EOS
      module fobis_test_m
        implicit none
        character(*), parameter :: message = "Hello FoBiS"
      end module
    EOS
    (testpath/"test-prog.f90").write <<~EOS
      program fobis_test
        use iso_fortran_env, only: stdout => output_unit
        use fobis_test_m, only: message
        implicit none
        write(stdout,'(A)') message
      end program
    EOS
    system "#{bin}/FoBiS.py", "build", "-compiler", "gnu"
    assert_match /Hello FoBiS/, shell_output(testpath/"test-prog")
  end
end

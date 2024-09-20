Facter.add("nodejs_installed_version") do
  confine :kernel => "Linux"
  setcode do
    Facter::Util::Resolution.exec('node -v 2> /dev/null')
  end
end

Facter.add("nodejs_installed_version") do
  confine :kernel => "windows"
  setcode do
    Facter::Util::Resolution.exec('node -v 2> $null')
  end
end

require 'spec_helper_acceptance'

case fact('osfamily')
when 'AIX'
  username  = 'root'
  groupname = 'system'
when 'Darwin'
  username  = 'root'
  groupname = 'wheel'
when 'windows'
  username  = 'Administrator'
  groupname = 'Administrators'
else
  username  = 'root'
  groupname = 'root'
end

describe 'basic concat test', :unless => UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do
  basedir = default.tmpdir('concat')

  shared_examples 'successfully_applied' do |pp|
    it 'applies the manifest twice with no stderr' do
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe file("#{default['puppetvardir']}/concat") do
      it { should be_directory }
      it { should be_owned_by username }
      it { should be_grouped_into groupname }
      it { should be_mode 755 }
    end
    describe file("#{default['puppetvardir']}/concat/bin") do
      it { should be_directory }
      it { should be_owned_by username }
      it { should be_grouped_into groupname }
      it { should be_mode 755 }
    end
    describe file("#{default['puppetvardir']}/concat/bin/concatfragments.sh") do
      it { should be_file }
      it { should be_owned_by username }
      #it { should be_grouped_into groupname }
      it { should be_mode 755 }
    end
    describe file("#{default['puppetvardir']}/concat/_tmp_concat_file") do
      it { should be_directory }
      it { should be_owned_by username }
      it { should be_grouped_into groupname }
      it { should be_mode 750 }
    end
    describe file("#{default['puppetvardir']}/concat/_tmp_concat_file/fragments") do
      it { should be_directory }
      it { should be_owned_by username }
      it { should be_grouped_into groupname }
      it { should be_mode 750 }
    end
    describe file("#{default['puppetvardir']}/concat/_tmp_concat_file/fragments.concat") do
      it { should be_file }
      it { should be_owned_by username }
      it { should be_grouped_into groupname }
      it { should be_mode 640 }
    end
    describe file("#{default['puppetvardir']}/concat/_tmp_concat_file/fragments.concat.out") do
      it { should be_file }
      it { should be_owned_by username }
      it { should be_grouped_into groupname }
      it { should be_mode 640 }
    end
  end

  context 'owner/group root' do
    pp = <<-EOS
      concat { '#{basedir}/file':
        owner => '#{username}',
        group => '#{groupname}',
        mode  => '0644',
      }

      concat::fragment { '1':
        target  => '#{basedir}/file',
        content => '1',
        order   => '01',
      }

      concat::fragment { '2':
        target  => '#{basedir}/file',
        content => '2',
        order   => '02',
      }
    EOS

    it_behaves_like 'successfully_applied', pp

    describe file('#{basedir}/file') do
      it { should be_file }
      it { should be_owned_by username }
      it { should be_grouped_into groupname }
      it { should be_mode 644 }
      it { should contain '1' }
      it { should contain '2' }
    end
    describe file("#{default['puppetvardir']}/concat/_tmp_concat_file/fragments/01_1") do
      it { should be_file }
      it { should be_owned_by username }
      it { should be_grouped_into groupname }
      it { should be_mode 640 }
    end
    describe file("#{default['puppetvardir']}/concat/_tmp_concat_file/fragments/02_2") do
      it { should be_file }
      it { should be_owned_by username }
      it { should be_grouped_into groupname }
      it { should be_mode 640 }
    end
  end

  context 'ensure' do
    context 'works when set to present with path set' do
      pp="
        concat { 'file':
          ensure => present,
          path   => '#{basedir}/file',
          mode   => '0644',
        }
        concat::fragment { '1':
          target  => 'file',
          content => '1',
          order   => '01',
        }
      "

      it_behaves_like 'successfully_applied', pp

      describe file('#{basedir}/file') do
        it { should be_file }
        it { should be_mode 644 }
        it { should contain '1' }
      end
    end
    context 'works when set to absent with path set' do
      pp="
        concat { 'file':
          ensure => absent,
          path   => '#{basedir}/file',
          mode   => '0644',
        }
        concat::fragment { '1':
          target  => 'file',
          content => '1',
          order   => '01',
        }
      "

      # Can't used shared examples as this will always trigger the exec when
      # absent is set.
      it 'applies the manifest twice with no stderr' do
        apply_manifest(pp, :catch_failures => true)
        apply_manifest(pp, :catch_changes => true)
      end

      describe file('#{basedir}/file') do
        it { should_not be_file }
      end
    end
  end
end
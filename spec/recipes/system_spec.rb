require 'spec_helper'

describe 'limits_test_cookbook::system' do

  subject do
    ChefSpec::SoloRunner.new(step_into: %w(limits_config)) do |node|
      allow(node).to receive(:name).and_return('limits-test-node')
    end.converge(described_recipe)
  end

  it do
    is_expected.to create_limits_config('system')
      .with(
        use_system: true,
        limits: [
          { domain: '*', type: 'hard', item: 'nofile', value: 12_345 },
          { domain: '*', type: 'soft', item: 'nofile', value: 5678 }
        ]
      )
  end

  it { is_expected.not_to create_directory('conf directory for system') }

  it do
    is_expected.to create_template('/etc/security/limits.conf')
      .with(
        cookbook: 'limits',
        source: 'limits.d.conf.erb',
        owner: 'root',
        group: 'root',
        mode: 0644,
        variables: {
          valid_limits: ['* hard nofile 12345',
                         '* soft nofile 5678'],
          invalid_limits: []
        }
      )
  end

  it do
    is_expected.to render_file('/etc/security/limits.conf')
      .with_content(
      <<-EOF
# Generated by Chef for node limits-test-node
# Local modifications will be overwritten!

* hard nofile 12345
* soft nofile 5678

# End of file
      EOF
      )
  end

end

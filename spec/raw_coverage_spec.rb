require "helper"

if SimpleCov.usable?
  describe SimpleCov::RawCoverage do
    describe "with two faked coverage resultsets" do
      before do
        @resultset1 = {
          source_fixture("sample.rb") => [nil, 1, 1, 1, nil, nil, 1, 1, nil, nil],
          source_fixture("app/models/user.rb") => [nil, 1, 1, 1, nil, nil, 1, 0, nil, nil],
          source_fixture("app/controllers/sample_controller.rb") => [nil, 1, 1, 1, nil, nil, 1, 0, nil, nil],
          source_fixture("resultset1.rb") => [1, 1, 1, 1],
          source_fixture("parallel_tests.rb") => [nil, 0, nil, 0],
          source_fixture("conditionally_loaded_1.rb") => [nil, 0, 1],  # loaded only in the first resultset
        }

        @resultset2 = {
          source_fixture("sample.rb") => [1, nil, 1, 1, nil, nil, 1, 1, nil, nil],
          source_fixture("app/models/user.rb") => [nil, 1, 5, 1, nil, nil, 1, 0, nil, nil],
          source_fixture("app/controllers/sample_controller.rb") => [nil, 3, 1, nil, nil, nil, 1, 0, nil, nil],
          source_fixture("resultset2.rb") => [nil, 1, 1, nil],
          source_fixture("parallel_tests.rb") => [nil, nil, 0, 0],
          source_fixture("conditionally_loaded_2.rb") => [nil, 0, 1],  # loaded only in the second resultset
        }
      end

      context "a merge" do
        subject do
          SimpleCov::RawCoverage.merge_results(@resultset1, @resultset2)
        end

        it "has proper results for sample.rb" do
          expect(subject[source_fixture("sample.rb")]).to eq([1, 1, 2, 2, nil, nil, 2, 2, nil, nil])
        end

        it "has proper results for user.rb" do
          expect(subject[source_fixture("app/models/user.rb")]).to eq([nil, 2, 6, 2, nil, nil, 2, 0, nil, nil])
        end

        it "has proper results for sample_controller.rb" do
          expect(subject[source_fixture("app/controllers/sample_controller.rb")]).to eq([nil, 4, 2, 1, nil, nil, 2, 0, nil, nil])
        end

        it "has proper results for resultset1.rb" do
          expect(subject[source_fixture("resultset1.rb")]).to eq([1, 1, 1, 1])
        end

        it "has proper results for resultset2.rb" do
          expect(subject[source_fixture("resultset2.rb")]).to eq([nil, 1, 1, nil])
        end

        it "has proper results for parallel_tests.rb" do
          expect(subject[source_fixture("parallel_tests.rb")]).to eq([nil, nil, nil, 0])
        end

        it "has proper results for conditionally_loaded_1.rb" do
          expect(subject[source_fixture("conditionally_loaded_1.rb")]).to eq([nil, 0, 1])
        end

        it "has proper results for conditionally_loaded_2.rb" do
          expect(subject[source_fixture("conditionally_loaded_2.rb")]).to eq([nil, 0, 1])
        end
      end
    end

    describe "with frozen resultsets" do
      before do
        @resultset1 = {
          source_fixture("sample.rb").freeze => [nil, 1, 1, 1, nil, nil, 1, 1, nil, nil].freeze,
          source_fixture("app/models/user.rb").freeze => [nil, 1, 1, 1, nil, nil, 1, 0, nil, nil].freeze,
        }.freeze

        @resultset2 = {
          source_fixture("sample.rb").freeze => [1, nil, 1, 1, nil, nil, 1, 1, nil, nil].freeze,
          source_fixture("app/models/user.rb").freeze => [nil, 1, 5, 1, nil, nil, 1, 0, nil, nil].freeze,
        }.freeze
      end

      it "can merge without exceptions" do
        SimpleCov::RawCoverage.merge_results(@resultset1, @resultset2)
      end
    end
  end
end

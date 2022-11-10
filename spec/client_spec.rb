require "spec_helper"

RSpec.describe Dune::Client do
  let(:key) { "key" }
  let(:logger) { double(:logger, info: true, warn: true, error: true) }
  let(:custom_url) { "https://custom-proxy.com" }
  let(:faraday_settings) do
    {
      url: "https://custom-proxy.com"
    }
  end

  describe "::new" do
    context "without faraday settings" do
      subject do
        described_class.new(api_key: key, logger: logger)
      end
      it "uses the default settings" do
        expect(subject.connection.headers).to eq({
          "Content-type"   => "application/json",
          "X-dune-api-key" => key,
          "User-Agent"     => "Faraday v2.6.0"
        })
      end
    end

    context "with faraday settings" do
      subject do
        described_class.new(api_key: key, logger: logger, faraday_settings: faraday_settings)
      end

      it "uses the faraday settings" do
        expect(subject.connection.url_prefix.to_s).to eq("#{custom_url}/")
      end
    end
  end

  describe "HTTP interactions" do
    let(:key) { ENV["DUNE_API_KEY"] }
    let(:max_gas_eth_price_query_id) { 312527 }
    let(:dex_by_volume_query_id) { 1572338 }
    let(:dex_by_volume_execution_id) { "01GHGT0WXHZ7PCA23R11PPN6TR" }
    let(:max_gas_eth_price_execution_id) { "01GHGBV67167FF47J3MF010A90" }

    subject do
      described_class.new(api_key: key)
    end

    describe "a failed interaction" do
      let(:key) { "bad-key" }

      it "throws a Dune::Error" do
        VCR.use_cassette("query/error") do
          expect { subject.query("foobar") }.to raise_error(Dune::Error)
        end
      end
    end

    describe "#query" do
      context "without parameters" do
        it "returns the execution ID and the state" do
          VCR.use_cassette("queries/#{max_gas_eth_price_query_id}/without_parameters/execute") do
            body = subject.query(max_gas_eth_price_query_id)
            expect(body).to eq({
              "execution_id" => max_gas_eth_price_execution_id,
              "state"        => "QUERY_STATE_EXECUTING"
            })
          end
        end
      end

      context "with parameters" do
        it "returns the execution ID and the state" do
          VCR.use_cassette("queries/#{dex_by_volume_query_id}/with_parameters/execute") do
            json = JSON.generate({ query_parameters: { grouping_parameter: 2 } })
            body = subject.query(dex_by_volume_query_id, json)
            expect(body).to eq({
              "execution_id" => dex_by_volume_execution_id,
              "state"        => "QUERY_STATE_PENDING"
            })
          end
        end
      end
    end

    describe "#execution_status" do
      it "returns the status object" do
        VCR.use_cassette("queries/#{max_gas_eth_price_execution_id}/status") do
          body = subject.execution_status(max_gas_eth_price_execution_id)
          expect(body).to eq({
            "execution_id"         => max_gas_eth_price_execution_id,
            "query_id"             => max_gas_eth_price_query_id,
            "state"                => "QUERY_STATE_FAILED",
            "submitted_at"         => "2022-11-10T08:52:29.026525Z",
            "expires_at"           => "2024-11-09T09:22:37.266988Z",
            "execution_started_at" => "2022-11-10T08:52:37.249545981Z",
            "execution_ended_at"   => "2022-11-10T09:22:37.266987958Z"
          })
        end
      end
    end

    describe "#execution" do
      let(:results) do
        "{\"execution_id\":\"01GHGT0WXHZ7PCA23R11PPN6TR\",\"query_id\":1572338,\"state\":\"QUERY_STATE_COMPLETED\",\"submitted_at\":\"2022-11-10T13:00:16.178634Z\",\"expires_at\":\"2024-11-09T13:00:18.743991Z\",\"execution_started_at\":\"2022-11-10T13:00:16.180711Z\",\"execution_ended_at\":\"2022-11-10T13:00:18.74399Z\",\"result\":{\"rows\":[{\"24 Hours Volume\":5147473869.405071,\"7 Days Volume\":16422493697.074032,\"Project\":\"Uniswap\",\"Rank\":1},{\"24 Hours Volume\":2128044339.045551,\"7 Days Volume\":4018636274.888033,\"Project\":\"Curve\",\"Rank\":2},{\"24 Hours Volume\":162471623.28743213,\"7 Days Volume\":1728450869.262495,\"Project\":\"DODO\",\"Rank\":3},{\"24 Hours Volume\":268336036.7564088,\"7 Days Volume\":834924684.8763739,\"Project\":\"Balancer\",\"Rank\":4},{\"24 Hours Volume\":98846012.99495272,\"7 Days Volume\":425875970.21048546,\"Project\":\"Sushiswap\",\"Rank\":5},{\"24 Hours Volume\":60366325.27197541,\"7 Days Volume\":234091878.86250496,\"Project\":\"0x Native\",\"Rank\":6},{\"24 Hours Volume\":16776560.360000972,\"7 Days Volume\":205751657.01641682,\"Project\":\"Shibaswap\",\"Rank\":7},{\"24 Hours Volume\":62489156.12979477,\"7 Days Volume\":186966471.53953952,\"Project\":\"1inch Limit Order Protocol\",\"Rank\":8},{\"24 Hours Volume\":7391479.829131125,\"7 Days Volume\":51038483.194361635,\"Project\":\"LINKSWAP\",\"Rank\":9},{\"24 Hours Volume\":15058603.021421395,\"7 Days Volume\":44839925.04208221,\"Project\":\"Kyber\",\"Rank\":10},{\"24 Hours Volume\":6238002.491748715,\"7 Days Volume\":28633027.283344224,\"Project\":\"Bancor Network\",\"Rank\":11},{\"24 Hours Volume\":11284291.458850972,\"7 Days Volume\":24863654.497600812,\"Project\":\"Synthetix\",\"Rank\":12},{\"24 Hours Volume\":3438698.5514774276,\"7 Days Volume\":22930935.100651845,\"Project\":\"airswap\",\"Rank\":13},{\"24 Hours Volume\":8459176.870255038,\"7 Days Volume\":19214785.597925544,\"Project\":\"Defi Swap\",\"Rank\":14},{\"24 Hours Volume\":3745305.33000484,\"7 Days Volume\":17967817.371807467,\"Project\":\"Clipper\",\"Rank\":15},{\"24 Hours Volume\":8289553.167613202,\"7 Days Volume\":12589363.16174549,\"Project\":\"mStable\",\"Rank\":16},{\"24 Hours Volume\":2330755.2788347583,\"7 Days Volume\":5599660.172261546,\"Project\":\"Smoothy Finance\",\"Rank\":17},{\"24 Hours Volume\":14816.268686953088,\"7 Days Volume\":2467542.6857055193,\"Project\":\"Sakeswap\",\"Rank\":18},{\"24 Hours Volume\":412549.61746334995,\"7 Days Volume\":1089226.270124683,\"Project\":\"Saddle\",\"Rank\":19},{\"24 Hours Volume\":14527.674615585389,\"7 Days Volume\":884010.5557267824,\"Project\":\"Shell\",\"Rank\":20},{\"24 Hours Volume\":105998.14252675601,\"7 Days Volume\":757276.5730266889,\"Project\":\"1inch LP\",\"Rank\":21},{\"24 Hours Volume\":178044.97305438892,\"7 Days Volume\":562457.5402067391,\"Project\":\"swapr\",\"Rank\":22},{\"24 Hours Volume\":77459.48598797187,\"7 Days Volume\":366161.80554620543,\"Project\":\"DefiPlaza\",\"Rank\":23},{\"24 Hours Volume\":84607.35890964951,\"7 Days Volume\":300828.22562092193,\"Project\":\"LuaSwap\",\"Rank\":24},{\"24 Hours Volume\":18622.650121442177,\"7 Days Volume\":262916.0231789891,\"Project\":\"Indexed Finance\",\"Rank\":25},{\"24 Hours Volume\":58042.590330936044,\"7 Days Volume\":180936.34261400532,\"Project\":\"Convergence\",\"Rank\":26},{\"24 Hours Volume\":114256.58559902287,\"7 Days Volume\":139176.5846827314,\"Project\":\"xSigma\",\"Rank\":27},{\"24 Hours Volume\":10400.73312688106,\"7 Days Volume\":110284.52363794927,\"Project\":\"PowerIndex\",\"Rank\":28},{\"24 Hours Volume\":8154.231550187072,\"7 Days Volume\":50803.09991247398,\"Project\":\"Mooniswap\",\"Rank\":29},{\"24 Hours Volume\":null,\"7 Days Volume\":48387.67464688124,\"Project\":\"Unifi\",\"Rank\":30},{\"24 Hours Volume\":3637.431799674949,\"7 Days Volume\":30639.615790693693,\"Project\":\"Integral\",\"Rank\":31},{\"24 Hours Volume\":null,\"7 Days Volume\":6876.22189442231,\"Project\":\"DFX Finance\",\"Rank\":32}],\"metadata\":{\"column_names\":[\"Rank\",\"Project\",\"7 Days Volume\",\"24 Hours Volume\"],\"result_set_bytes\":1912,\"total_row_count\":32,\"datapoint_count\":132,\"pending_time_millis\":2,\"execution_time_millis\":2563}}}"
      end
      it "returns the results of a query" do
        VCR.use_cassette("queries/#{dex_by_volume_query_id}/with_parameters/results") do
          body = subject.execution(dex_by_volume_execution_id)
          expect(body).to eq(JSON.parse(results))
        end
      end
    end

    describe "#cancel_execution" do
      let(:new_id) { 469990 }

      it "cancels a query" do
        VCR.use_cassette("queries/#{new_id}/cancel") do
          query = subject.query(new_id)
          id    = query["execution_id"]
          out   = subject.cancel(id)
          expect(out).to eq({
            "success" => true
          })
        end
      end
    end
  end
end

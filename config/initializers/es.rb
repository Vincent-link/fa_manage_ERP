#Elasticsearch::Model.client = Elasticsearch::Client.new host: Settings.es_host
ENV["ELASTICSEARCH_URL"] = Settings.es_host
DEFAULT_HL_TAG = {tag: '<span class="highlight">'}

Searchkick.model_options = {
    language: 'chinese'
}
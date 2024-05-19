import json
import prometheus_client
import subprocess

class LibrespeedCollector:
  def __init__(self, logger):
    self.logger = logger

  def get_results(self):
    self.logger.debug('get res')

    res = subprocess.run(['/opt/librespeed-exporter/librespeed-cli', '--json', '--server', '85'], capture_output = True, text = True, check = True)
    self.logger.debug('got res')

    return json.loads(res.stdout)[0]

  def collect(self):
    self.logger.info('collect start')
    res = self.get_results()

    yield self.gauge_download(res)
    yield self.gauge_upload(res)
    yield self.gauge_ping(res)
    yield self.gauge_jitter(res)

    self.logger.info('collect done')

  def gauge_download(self, data):
    self.logger.debug('gauge DL')

    gauge = prometheus_client.metrics_core.GaugeMetricFamily('librespeed_download_bps', 'Download speed in bits per second', labels = ['server'])
    gauge.add_metric([data['server']['url']], data['download'] * 1000000)

    self.logger.debug('gauge DL done')

    return gauge

  def gauge_upload(self, data):
    self.logger.debug('gauge UL')

    gauge = prometheus_client.metrics_core.GaugeMetricFamily('librespeed_upload_bps', 'Upload speed in bits per second', labels = ['server'])
    gauge.add_metric([data['server']['url']], data['upload'] * 1000000)

    self.logger.debug('gauge UL done')

    return gauge

  def gauge_ping(self, data):
    self.logger.debug('gauge ping')

    gauge = prometheus_client.metrics_core.GaugeMetricFamily('librespeed_ping_seconds', 'Ping in seconds', labels = ['server'])
    gauge.add_metric([data['server']['url']], data['ping'] / 1000)

    self.logger.debug('gauge ping done')

    return gauge

  def gauge_jitter(self, data):
    self.logger.debug('gauge jitter')

    gauge = prometheus_client.metrics_core.GaugeMetricFamily('librespeed_jitter_seconds', 'Jitter in seconds', labels = ['server'])
    gauge.add_metric([data['server']['url']], data['jitter'] / 1000)

    self.logger.debug('gauge jitter done')

    return gauge

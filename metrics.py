from prometheus_client import Counter

class Metrics:
    def __init__(self):
        self.counters = {
            'requests': Counter('requests', 'Requests count'),
            'exceptions': Counter('exceptions', 'Exceptions count'),
            'errors': Counter('errors', 'Errors count')
        }

    def inc(self, counter):
        if counter not in self.counters:
            return
        self.counters[counter].inc()

stats = Metrics()

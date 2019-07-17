import multiprocessing as mp
import socket
from subprocess import Popen, PIPE
from multiprocessing import Queue, Process


class Network:
    # Class variables
    IPnetwork = []
    StartIP = ""
    EndIP = ""
    IPrange = mp.Queue()
    ActiveIPs = mp.Queue()
    Hostnames = mp.Queue()

    # Get IP range
    def getiprange(self):
        self.IPnetwork = input("Enter a(n) IP network(s) (x.x.x x.x.x): ").split(' ')
        self.StartIP = input("Enter a start IP: ")
        self.StartIP = int(self.StartIP)
        self.EndIP = input("Enter an end IP: ")
        self.EndIP = int(self.EndIP)
        for i in self.IPnetwork:
            while self.StartIP <= self.EndIP:
                temp = str(self.StartIP)
                self.IPrange.put(str(i) + "." + temp)
                self.StartIP += 1

    # Get active hosts
    def gethosts(self, ipaddr):
        toping = Popen(['ping', '-c', '1', '-i', '1', ipaddr], stdout=PIPE)
        output = toping.communicate()[0]
        hostalive = toping.returncode
        if hostalive == 0:
            self.ActiveIPs.put(ipaddr)

    # Get host names
    def gethostnames(self):
        while not self.ActiveIPs.empty():
            ip = self.ActiveIPs.get()
            hostn = socket.getfqdn(ip)
            temp = hostn + "\t " + ip
            self.Hostnames.put(temp)

    # Multiprocessor (Limit of 50 threads set to prevent maxing the CPU)
    def fast(self):
        count = self.IPrange.qsize()
        threads = 0
        while count > 0:
            count -= 1
            proc = mp.Process(target=self.gethosts, args=(self.IPrange.get(),))
            proc.start()
            threads += 1
            if threads == 50:
                proc.join()
                threads = 0

    # Print active hosts
    def printhosts(self):
        count = self.Hostnames.qsize()
        while count > 0:
            print(self.Hostnames.get())
            count -= 1



Scan = Network()

Scan.getiprange()

Scan.fast()

Scan.gethostnames()

Scan.printhosts()

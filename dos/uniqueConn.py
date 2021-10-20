class UniqueConn:
    def __init__(self, srcIp, destIp, srcPort, destPort):
        self._srcIp = srcIp
        self._destIp = destIp
        self._srcPort = srcPort
        self._destPort = destPort

    @property
    def srcIp(self):
        return self._srcIp
    
    @property
    def destIp(self):
        return self._destIp

    @property
    def srcPort(self):
        return self._srcPort

    @property
    def destPort(self):
        return self._destPort

    # Check if two connections are equals
    def __eq__(self, other):
        if isinstance(other, UniqueConn):
            checkSrcIp = (self._srcIp == other.srcIp or self._srcIp == other.destIp)
            checkDstIp = (self._destIp == other.destIp or self._destIp == other.srcIp)
            checkSrcPort = (self._srcPort == other.srcPort or self._srcPort == other.destPort)
            checkDestPort = (self._destPort == other.destPort or self._destPort == other.srcPort)
            return checkSrcIp and checkDstIp and checkSrcPort and checkDestPort
        return False

    def __str__(self):
        return f"Source Ip: {self._srcIp}, Destination Ip: {self._destIp}, Source Port: {self._srcPort}, Destination Port: {self._destPort}"        

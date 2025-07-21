window.ethereum = {
    isConnected: true,
    request: (payload) => {
        return new Promise((resolve, reject) => {
            window.webkit.messageHandlers.ethereum.postMessage(payload);
        });
    },
    enable: () => window.ethereum.request({method: 'eth_requestAccounts'}),
    
    // 设置当前地址
    setAddress: (address) => {
        window.ethereum.selectedAddress = address;
        window.ethereum.accounts = [address];
    },
    
    // BSC网络信息
    chainId: '0x61',        // 十六进制的97 = 十进制的97
    networkVersion: '97',    // BSC测试网
    isMetaMask: false,
    _metamask: { isUnlocked: true }
};
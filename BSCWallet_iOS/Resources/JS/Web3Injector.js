// Web3注入脚本
(function() {
    if (typeof window.ethereum !== 'undefined') {
        console.log('Web3 provider already exists');
        return;
    }
    
    const eventListeners = [];
    const responseEvents = [];
    
    // 创建以太坊提供者对象
    const ethereum = {
        isConnected: true,
        chainId: '0x61', // BSC测试网ID
        networkVersion: '97',
        selectedAddress: null,
        accounts: [],
        
        // 请求方法
        request: (payload) => {
            return new Promise((resolve, reject) => {
                // 发送消息到原生应用
                window.webkit.messageHandlers.ethereum.postMessage(payload);
                
                // 监听响应事件
                const eventName = `ethereumResponse_${Date.now()}`;
                responseEvents.push(eventName);
                
                window.addEventListener(eventName, (event) => {
                    if (event.detail.error) {
                        reject(event.detail.error);
                    } else {
                        resolve(event.detail.result);
                    }
                });
            });
        },
        
        // 兼容旧版方法
        enable: () => ethereum.request({method: 'eth_requestAccounts'}),
        send: (method, params) => ethereum.request({method, params}),
        
        // 事件监听
        on: (event, listener) => {
            eventListeners.push({event, listener});
        },
        
        // 触发事件
        emit: (event, data) => {
            eventListeners.forEach(item => {
                if (item.event === event) {
                    item.listener(data);
                }
            });
        },
        
        // 设置当前地址
        setAddress: (address) => {
            ethereum.selectedAddress = address;
            ethereum.accounts = [address];
            ethereum.emit('accountsChanged', [address]);
        }
    };
    
    window.ethereum = ethereum;
    console.log('BSC Wallet Web3 injected');
})();

//import './App.css';
import Web3 from 'web3';

function App() {

  if (typeof window.ethereum !== 'undefined') {
    console.log('MetaMask is installed!');
  }

  const openMetamask = () => {
    window.ethereum.request({ method: 'eth_requestAccounts' });
  }

  const test = () => {
    console.log('test', new Web3(window.ethereum));
  }

  return (
    <div className="App">
      <ol>
        <li>
          <button onClick={openMetamask}>openMetamask</button>
        </li>
        <li>
          <button onClick={test}>test</button>
        </li>
      </ol>
      {/* <button onClick={initWeb3}>initWeb3</button> */}
    </div>
  );
}

export default App;

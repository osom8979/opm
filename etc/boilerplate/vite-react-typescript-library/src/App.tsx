import osomRunLogo from './assets/osom.run.svg';
import styles from './App.module.scss';

function App() {
  return (
    <div className={styles.root}>
      <a href="https://osom.run" target="_blank">
        <img src={osomRunLogo} alt="osom-ui logo" />
      </a>
    </div>
  );
}

export default App;

import { Switch } from "antd";
import React, { useEffect, useState } from "react";
import { useThemeSwitcher } from "react-css-theme-switcher";

export default function ThemeSwitch() {
  const theme = window.localStorage.getItem("theme");
  const [isDarkMode, setIsDarkMode] = useState(!(!theme || theme === "light"));
  const { switcher, currentTheme, themes } = useThemeSwitcher();

  useEffect(() => {
    if(!theme) toggleTheme(true);
    window.localStorage.setItem("theme", currentTheme);
  }, [currentTheme]);

  const toggleTheme = isChecked => {
    setIsDarkMode(isChecked);
    switcher({ theme: isChecked ? themes.dark : themes.light });
  };

  return (
    <div className="main fade-in" style={{ position: "fixed", right: 8, bottom: 8 }}>
      <span style={{ padding: 8 }}>{currentTheme === "light" ? "☀️" : "🌜"}</span>
      <Switch checked={isDarkMode} onChange={toggleTheme} />
    </div>
  );
}
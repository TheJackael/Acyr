import Roact from "@rbxts/roact";
import { hooked, useState } from "@rbxts/roact-hooked";
import Canvas from "components/Canvas";
import Card from "components/Card";
import { useTheme } from "hooks/use-theme";
import { DashboardPage } from "store/models/dashboard.model";
import { px } from "utils/udim2";

function ScriptExecutor() {
	const theme = useTheme("home").profile;
	const [script, setScript] = useState("");
	const [output, setOutput] = useState("");

	const handleExecute = () => {
		// Execute script logic here
		setOutput("Script executed successfully!");
	};

	return (
		<Card
			index={3}
			page={DashboardPage.Home}
			theme={theme}
			size={px(326, 250)}
			position={new UDim2(1, -(326 * 3 + 48 * 3), 0, 48)}
		>
			<textlabel
				Text="Script Executor"
				Font="GothamBlack"
				TextSize={20}
				TextColor3={theme.foreground}
				Position={px(24, 24)}
				BackgroundTransparency={1}
			/>
			
			{/* Input area */}
			<textbox
				Text={script}
				PlaceholderText="Enter your script here..."
				Position={px(24, 60)}
				Size={px(278, 120)}
				BackgroundColor3={theme.background}
				TextColor3={theme.foreground}
				[Roact.Change.Text] = {(rbx: TextBox) => setScript(rbx.Text)}
			/>

			{/* Execute button */}
			<textbutton
				Text="Execute"
				Position={px(24, 190)}
				Size={px(278, 40)}
				BackgroundColor3={theme.foreground}
				TextColor3={theme.background}
				Font="GothamBold"
				TextSize={14}
				[Roact.Event.MouseButton1Click] = {() => handleExecute()}
			/>
		</Card>
	);
}

export default hooked(ScriptExecutor);

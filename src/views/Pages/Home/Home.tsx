import Roact from "@rbxts/roact";
import { pure } from "@rbxts/roact-hooked";
import Canvas from "components/Canvas";
import { useScale } from "hooks/use-scale";
import { scale } from "utils/udim2";
import FriendActivity from "./FriendActivity";
import Profile from "./Profile";
import Server from "./Server";
import Title from "./Title";
import ScriptExecutor from "./ScriptExecutor";

function Home() {
	const scaleFactor = useScale();

	return (
		<Canvas position={scale(1, 1)} anchor={new Vector2(1, 1)}>
			<uiscale Scale={scaleFactor} />
			<Title />
			<Server />
			<FriendActivity />
			<Profile />
			<ScriptExecutor />
		</Canvas>
	);
}

export default pure(Home);

import Roact from "@rbxts/roact";
import { hooked, useMemo } from "@rbxts/roact-hooked";
import Canvas from "components/Canvas";
import { ScaleContext } from "context/scale-context";
import { hooked } from "@rbxts/roact-hooked";
import { useAppSelector } from "hooks/common/rodux-hooks";
import { useSpring } from "hooks/common/use-spring";
import { useViewportSize } from "hooks/common/use-viewport-size";
import { hex } from "utils/color3";
import { map } from "utils/number-util";
import { scale } from "utils/udim2";
import Hint from "views/Hint";
import Clock from "../Clock";
import Navbar from "../Navbar";
import Pages from "../Pages";
import { px, scale } from "utils/udim2";

// Minimum/maximum screen height that will cause the padding to decrease. Avoids
// rescaling the UI for as long as possible.
const PADDING_MIN_HEIGHT = 980;
const PADDING_MAX_HEIGHT = 1080;

// Minimum/maximum padding to apply to the UI.
const MIN_PADDING_Y = 14;
const MAX_PADDING_Y = 48;

function getPaddingY(height: number) {
	if (height < PADDING_MAX_HEIGHT && height >= PADDING_MIN_HEIGHT) {
		return map(height, PADDING_MIN_HEIGHT, PADDING_MAX_HEIGHT, MIN_PADDING_Y, MAX_PADDING_Y);
	} else if (height < PADDING_MIN_HEIGHT) {
		return MIN_PADDING_Y;
	} else {
		return MAX_PADDING_Y;
	}
interface SectionCardProps {
	title: string;
	position: UDim2;
	size: UDim2;
	items: string[];
	highlighted?: number[];
}

function getScale(height: number) {
	if (height < PADDING_MIN_HEIGHT) {
		return map(height, PADDING_MIN_HEIGHT, 130, 1, 0);
	} else {
		return 1;
	}
function SectionCard({ title, position, size, items, highlighted = [] }: SectionCardProps) {
	return (
		<frame Size={size} Position={position} BackgroundTransparency={1}>
			<frame Size={scale(1, 0)} BackgroundColor3={hex("#07090f")} BorderSizePixel={0}>
				<uicorner CornerRadius={new UDim(0, 24)} />
				<textlabel
					Text={title}
					Font={Enum.Font.Gotham}
					TextSize={28}
					TextColor3={hex("#f6f6f6")}
					BackgroundTransparency={1}
					Size={scale(1, 1)}
				/>
			</frame>

			<frame
				Size={new UDim2(1, 0, 1, -68)}
				Position={px(0, 68)}
				BackgroundColor3={hex("#13151b")}
				BorderSizePixel={0}
			>
				<uicorner CornerRadius={new UDim(0, 24)} />
				<uilistlayout FillDirection="Vertical" HorizontalAlignment="Center" Padding={new UDim(0, 6)} />
				<uipadding PaddingTop={new UDim(0, 8)} PaddingLeft={new UDim(0, 8)} PaddingRight={new UDim(0, 8)} PaddingBottom={new UDim(0, 8)} />
				{items.map((item, index) => (
					<textlabel
						Key={`${title}-${item}`}
						Text={item}
						Font={Enum.Font.Gotham}
						TextSize={31}
						TextColor3={hex("#f2f2f2")}
						Size={new UDim2(1, 0, 0, 44)}
						BackgroundColor3={highlighted.includes(index) ? hex("#ff4a38") : hex("#13151b")}
						BackgroundTransparency={highlighted.includes(index) ? 0 : 1}
						BorderSizePixel={0}
					>
						<uicorner CornerRadius={new UDim(0, 10)} />
					</textlabel>
				))}
			</frame>
		</frame>
	);
}

function Dashboard() {
	const viewportSize = useViewportSize();
	const isOpen = useAppSelector((state) => state.dashboard.isOpen);

	const [scaleFactor, padding] = useMemo(() => {
		return [viewportSize.map((s) => getScale(s.Y)), viewportSize.map((s) => getPaddingY(s.Y))];
	}, [viewportSize]);

	return (
		<ScaleContext.Provider value={scaleFactor}>
			{/* Shading */}
		<frame Size={scale(1, 1)} BackgroundTransparency={1}>
			<imagelabel
				Size={scale(1, 1)}
				Image="rbxassetid://10994377692"
				ScaleType="Crop"
				ImageColor3={hex("#c9c9c9")}
				ImageTransparency={useSpring(isOpen ? 0.6 : 1, {})}
				BorderSizePixel={0}
			>
			</imagelabel>

			<frame
				Size={scale(1, 1)}
				BackgroundColor3={hex("#000000")}
				BackgroundTransparency={useSpring(isOpen ? 0 : 1, {})}
				BackgroundTransparency={useSpring(isOpen ? 0.48 : 1, {})}
				BorderSizePixel={0}
			>
				<uigradient Transparency={new NumberSequence(1, 0.25)} Rotation={90} />
			</frame>
			/>

			{/* Body */}
			<Canvas
				padding={{
					top: 48,
					bottom: padding,
					left: 48,
					right: 48,
				}}
			<frame
				Size={px(2060, 560)}
				Position={px(56, 56)}
				BackgroundTransparency={1}
				Visible={isOpen}
			>
				<Canvas
					padding={{
						bottom: padding.map((p) => 56 + p), // Navbar height + padding
					}}
				>
					<Pages />
					<Hint />
				</Canvas>
				<Navbar />
				<Clock />
			</Canvas>
		</ScaleContext.Provider>
				<SectionCard
					title="Combat"
					position={px(0, 0)}
					size={px(300, 240)}
					items={["InstantReload", "NoSpread", "Aura"]}
					highlighted={[0, 1]}
				/>
				<SectionCard
					title="Render"
					position={px(380, 0)}
					size={px(300, 520)}
					items={[
						"NoAnimation",
						"HitSounds",
						"Id",
						"Sparkle",
						"Nametags",
						"HitEffects",
						"Selected",
						"Clone, Void",
						"damage numbers",
						"NoRecoil",
					]}
					highlighted={[5, 9]}
				/>
				<SectionCard
					title="Movement"
					position={px(760, 0)}
					size={px(300, 140)}
					items={["Gravity"]}
				/>
				<SectionCard title="Player" position={px(1140, 0)} size={px(300, 90)} items={[]} />
				<SectionCard
					title="Other"
					position={px(1520, 0)}
					size={px(300, 160)}
					items={["AutoMoney", "Unload"]}
				/>
			</frame>
		</frame>
	);
}

export default hooked(Dashboard);
